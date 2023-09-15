module Otel.Effect.Static (
  Otel,
  runOtelStatic,
  withInstrumentationScope,
  withAttributes,
  metrics,
  log,
  traceSpan,
  traceEvent,
  spanLink,
) where

import Control.Concurrent.STM
import Control.Monad (when)
import Control.Monad.Catch (SomeException, catch, mask, throwM)
import Data.Maybe (isJust)
import Data.ProtoLens (defMessage)
import Data.Time (UTCTime, getCurrentTime, nominalDiffTimeToSeconds)
import Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import Data.Vector (Vector, cons)
import Data.Word (Word64)
import Effectful (Dispatch (Static), DispatchOf, Eff, Effect, IOE, liftIO, type (:>))
import Effectful.Dispatch.Static (SideEffects (WithSideEffects), StaticRep, evalStaticRep, getStaticRep, localStaticRep, stateStaticRep, unsafeEff_)
import GHC.Generics
import GHC.TypeLits (KnownSymbol)
import Lens.Micro ((&), (.~), (?~))
import Otel.Internal.Client (OtelClient (..))
import Otel.Internal.OtelQueue
import Otel.Internal.Type (Attributes, LogData (..), Scope (..), ScopeData, SpanId, SpanLink (..), SpanStatus (..), TraceData (..), TraceEvent (..), TraceId, fromSpanId, fromTraceId, getRandomSpanId, getRandomTraceId, logLevelToSeverityNumber, logLevelToSeverityText, toOtelAttributes, toOtelSpanKind, toOtelSpanLinks, toOtelSpanStatus, toScopeData)
import Proto.Opentelemetry.Proto.Common.V1.Common (AnyValue)
import Proto.Opentelemetry.Proto.Logs.V1.Logs (LogRecord)
import Proto.Opentelemetry.Proto.Metrics.V1.Metrics (Metric)
import Proto.Opentelemetry.Proto.Trace.V1.Trace (Span, Span'Event)
import Prelude hiding (log)

-- | Logging/Tracing/Metrics effect. This effect is static one. It is better to
-- use the dynamic one in the `Otel.Effect` module.
data Otel :: Effect

type instance DispatchOf Otel = 'Static 'WithSideEffects

data instance StaticRep Otel = OtelState
  { createInstrumentedLogQueue :: ScopeData -> STM (OtelSingleQueue LogRecord)
  , createInstrumentedTraceQueue :: ScopeData -> STM (OtelSingleQueue Span)
  , instrumentedLogQueue :: OtelSingleQueue LogRecord
  , instrumentedTraceQueue :: OtelSingleQueue Span
  , globalAttributes :: Attributes
  , mTraceAndSpanIds :: Maybe (TraceId, SpanId)
  , events :: Vector Span'Event
  , logEnabled :: Bool
  , traceEnabled :: Bool
  }
  deriving stock (Generic)

globalTypeScope :: Scope "global" "0.0.0"
globalTypeScope = Scope

-- | Run the static effect and create the root trace if the trace data are
-- provided. If the trace data is not provided any subsequent trace calls will
-- be ignored.
runOtelStatic ::
  (IOE :> es) => OtelClient -> Maybe TraceData -> Eff (Otel : es) a -> Eff es a
runOtelStatic OtelClient {..} mRootTraceData m = do
  let globalScope = toScopeData globalTypeScope
  let createInstrumentedLogQueue scope = getSingleQueue scope logQueueSet
  let createInstrumentedTraceQueue scope = getSingleQueue scope traceQueueSet
  instrumentedLogQueue <- liftIO . atomically $ getSingleQueue globalScope logQueueSet
  instrumentedTraceQueue <- liftIO . atomically $ getSingleQueue globalScope traceQueueSet
  let state =
        OtelState
          { globalAttributes = mempty
          , mTraceAndSpanIds = Nothing
          , events = mempty
          , ..
          }
  let rootAction = case mRootTraceData of
        Just traceData | traceEnabled -> rootTrace traceData
        _otherwise -> id
  evalStaticRep state $ rootAction m

-- | Change the instrumentation scope. This function should be used by
-- instrumented/instrumentation libraries/components to indicate the
-- library/component name and version.
withInstrumentationScope ::
  forall name version m a.
  (KnownSymbol name, KnownSymbol version, Otel :> m) =>
  Scope name version ->
  Eff m a ->
  Eff m a
withInstrumentationScope typeScope m = do
  OtelState {..} <- getStaticRep
  let scope = toScopeData typeScope
  newLogQueue <- unsafeEff_ . atomically $ createInstrumentedLogQueue scope
  newTraceQueue <- unsafeEff_ . atomically $ createInstrumentedTraceQueue scope
  localStaticRep (modifyScope newLogQueue newTraceQueue) m
  where
    modifyScope ::
      OtelSingleQueue LogRecord ->
      OtelSingleQueue Span ->
      StaticRep Otel ->
      StaticRep Otel
    modifyScope newLogQueue newTraceQueue otelState =
      otelState
        { instrumentedLogQueue = newLogQueue
        , instrumentedTraceQueue = newTraceQueue
        }

-- | Allows to add attributes to subsequent calls of log/trace/metric functions.
-- Attribute name should be in 'abc.def.ghi` format, and they have to be unique
-- across the whole trace or they will be rewritten.
withAttributes :: (Otel :> m) => Attributes -> Eff m a -> Eff m a
withAttributes attributes = localStaticRep modifyAttrubutes
  where
    modifyAttrubutes :: StaticRep Otel -> StaticRep Otel
    modifyAttrubutes otelState =
      otelState
        { globalAttributes = globalAttributes otelState <> attributes
        }

-- FIXME: Maybe it could be implemented :D
metrics :: Vector Metric -> Eff m ()
metrics = undefined

nanosSinceEpoch :: UTCTime -> Word64
nanosSinceEpoch =
  floor . (1e9 *) . nominalDiffTimeToSeconds . utcTimeToPOSIXSeconds

-- | The most general logging function.
log :: (Otel :> m) => LogData -> Eff m ()
log LogData {..} = do
  otelState@OtelState {..} <- getStaticRep
  when logEnabled $ do
    time <- unsafeEff_ getCurrentTime
    unsafeEff_ . atomically . insertIntoSingeQueue instrumentedLogQueue $
      mkLogRecord otelState time
  where
    mkLogRecord :: StaticRep Otel -> UTCTime -> LogRecord
    mkLogRecord OtelState {..} time =
      defMessage
        & #severityText .~ logLevelToSeverityText logLevel
        & #severityNumber .~ logLevelToSeverityNumber logLevel
        & #body .~ messageBody
        & #vec'attributes .~ toOtelAttributes (globalAttributes <> attributes)
        & #timeUnixNano .~ nanosSinceEpoch time
        & mkIds mTraceAndSpanIds

    mkIds :: Maybe (TraceId, SpanId) -> LogRecord -> LogRecord
    mkIds = \case
      Nothing -> id
      Just (traceId, spanId) ->
        (#traceId .~ fromTraceId traceId)
          . (#spanId .~ fromSpanId spanId)

    messageBody :: AnyValue
    messageBody =
      defMessage
        & #maybe'stringValue ?~ message

runWithTrace ::
  forall es a.
  (Otel :> es) =>
  TraceData ->
  Eff es a ->
  OtelSingleQueue Span ->
  Attributes ->
  Maybe SpanId ->
  TraceId ->
  SpanId ->
  Eff es a
runWithTrace traceData m traceQueue globalAttributes mOldSpanId traceId newSpanId = mask $ \unmask -> do
  startTime <- unsafeEff_ getCurrentTime

  (events', ret) <- catch (unmask go) (handleError startTime)

  endTime <- unsafeEff_ getCurrentTime
  unsafeEff_ . atomically . insertIntoSingeQueue traceQueue $
    mkSpan traceData globalAttributes startTime endTime mOldSpanId traceId newSpanId events' SpanOk
  pure ret
  where
    go :: Eff es (Vector Span'Event, a)
    go = localStaticRep (newTraceLayer (traceId, newSpanId)) $ appInNewLayer m

    handleError :: UTCTime -> SomeException -> Eff es (Vector Span'Event, a)
    handleError startTime e = do
      endTime <- unsafeEff_ getCurrentTime
      unsafeEff_ . atomically . insertIntoSingeQueue traceQueue $
        mkSpan traceData globalAttributes startTime endTime mOldSpanId traceId newSpanId mempty $
          SpanError "Exceptions was raised during this span."
      throwM e

rootTrace :: forall es a. (Otel :> es) => TraceData -> Eff es a -> Eff es a
rootTrace traceData m = do
  OtelState {..} <- getStaticRep
  newSpanId <- unsafeEff_ getRandomSpanId
  traceId <- unsafeEff_ getRandomTraceId
  runWithTrace traceData m instrumentedTraceQueue globalAttributes Nothing traceId newSpanId

-- | Create a new span.
traceSpan :: forall es a. (Otel :> es) => TraceData -> Eff es a -> Eff es a
traceSpan traceData m = do
  OtelState {..} <- getStaticRep
  case mTraceAndSpanIds of
    -- Missing `traceId` means the tracing is disabled for this transaction.
    -- So the action is executed without changing the tracing scope and without
    -- doing tracing request.
    Nothing -> m
    -- Skip tracing when disabled.
    Just _ | not traceEnabled -> m
    Just (traceId, oldSpanId) -> do
      newSpanId <- unsafeEff_ getRandomSpanId
      runWithTrace traceData m instrumentedTraceQueue globalAttributes (Just oldSpanId) traceId newSpanId

-- Each layer gets new `OtelState` with empty events. The collection of
-- events is then returned, so they can be logged as part of the trace.
appInNewLayer :: (Otel :> es) => Eff es a -> Eff es (Vector Span'Event, a)
appInNewLayer m = do
  ret <- m
  OtelState {..} <- getStaticRep
  pure (events, ret)

mkSpan ::
  TraceData ->
  Attributes ->
  UTCTime ->
  UTCTime ->
  Maybe SpanId ->
  TraceId ->
  SpanId ->
  Vector Span'Event ->
  SpanStatus ->
  Span
mkSpan TraceData {..} globalAttrubutes startTime endTime mOldSpanId traceId newSpanId events' spanStatus =
  defMessage
    & #traceId .~ fromTraceId traceId
    & #spanId .~ fromSpanId newSpanId
    & #parentSpanId .~ maybe mempty fromSpanId mOldSpanId
    & #name .~ name
    & #kind .~ toOtelSpanKind kind
    & #startTimeUnixNano .~ nanosSinceEpoch startTime
    & #endTimeUnixNano .~ nanosSinceEpoch endTime
    & #vec'attributes .~ toOtelAttributes (attributes <> globalAttrubutes)
    & #vec'events .~ events'
    & #vec'links .~ toOtelSpanLinks spanLinks
    & #status .~ toOtelSpanStatus spanStatus

-- The layers work like stack the top of the stack is current context that
-- gets to be turned into a trace.
newTraceLayer :: (TraceId, SpanId) -> StaticRep Otel -> StaticRep Otel
newTraceLayer (traceId, newSpanId) otelState =
  otelState
    { mTraceAndSpanIds = Just (traceId, newSpanId)
    , events = mempty
    }

-- | Otel traces allow to add significant events into the trace trace
-- directly. The difference with logs is that logs are only linked to traces,
-- but the events are embedded in traces. This also means that when traces
-- are disabled the events will not be collected.
traceEvent :: (Otel :> es) => TraceEvent -> Eff es ()
traceEvent TraceEvent {..} = do
  time <- unsafeEff_ getCurrentTime
  OtelState {..} <- getStaticRep
  when (isJust mTraceAndSpanIds) $ stateStaticRep (addEvent time)
  where
    addEvent :: UTCTime -> StaticRep Otel -> ((), StaticRep Otel)
    addEvent time otelState =
      ((), otelState {events = cons (mkEvent time) $ events otelState})

    mkEvent :: UTCTime -> Span'Event
    mkEvent time =
      defMessage
        & #name .~ name
        & #vec'attributes .~ toOtelAttributes attributes
        & #timeUnixNano .~ nanosSinceEpoch time

-- | Faction for fetching links to the current spans/traces. This enables
-- developers to link, for example, cron jobs to the originating request that
-- triggered the cron job.
spanLink :: (Otel :> es) => Eff es (Maybe SpanLink)
spanLink = do
  OtelState {..} <- getStaticRep
  pure $ case mTraceAndSpanIds of
    Nothing -> Nothing
    Just (traceId, spanId) ->
      Just $
        SpanLink
          { traceId = traceId
          , spanId = spanId
          , attributes = mempty
          }
