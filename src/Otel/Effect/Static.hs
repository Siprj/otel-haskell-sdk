{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
module Otel.Effect.Static
  ( Otel
  , withInstrumentationScope
  , withAttributes
  , metrics
  , log
  , trace
  )
where

import Prelude (undefined, Maybe, ($), IO, (.), floor, (*), pure, id, mempty)
import Effectful (Effect, DispatchOf, Dispatch (Static), type (:>), Eff)
import Effectful.Dispatch.Static (StaticRep, SideEffects (WithSideEffects), localStaticRep, getStaticRep, unsafeEff_)
import Data.Vector (Vector)
import Otel.Type (LogData(..), TraceData (..), Scope, toOtelInstrumentationScope, Attributes, TraceId, SpanId, logLevelToSeverityText, logLevelToSeverityNumber, fromTraceId, fromSpanId, toOtelSpanKind, toOtelSpanLinks, toOtelSpanStatus, SpanStatus (..), getRandomSpanId, )
import Proto.Opentelemetry.Proto.Metrics.V1.Metrics (Metric)
import Proto.Opentelemetry.Proto.Common.V1.Common (InstrumentationScope, AnyValue)
import Data.Time (UTCTime, nominalDiffTimeToSeconds)
import Proto.Opentelemetry.Proto.Logs.V1.Logs (LogRecord)
import Data.Semigroup ((<>))
import Data.Time.Clock (getCurrentTime)
import Data.ProtoLens (defMessage)
import Lens.Micro ((&), (.~), (?~))
import Data.Maybe (Maybe (Nothing, Just))
import Data.Word (Word64)
import Data.Time.Clock.POSIX (utcTimeToPOSIXSeconds)
import Proto.Opentelemetry.Proto.Trace.V1.Trace (Span, Span'Event)

data Otel :: Effect


type instance DispatchOf Otel = 'Static 'WithSideEffects
data instance StaticRep Otel = OtelState
  { instrumentationScope :: InstrumentationScope
  , globalAttributes :: Attributes
  , mTraceAndSpanIds :: Maybe (TraceId, SpanId)
  , sendLog :: LogRecord -> IO ()
  , sendTrace :: Span -> IO ()
  , events :: Vector Span'Event
  }

withInstrumentationScope :: (Otel :> m) => Scope -> Eff m a -> Eff m a
withInstrumentationScope scope = localStaticRep modifyScope
  where
    modifyScope :: StaticRep Otel -> StaticRep Otel
    modifyScope otelState = otelState
      { instrumentationScope = toOtelInstrumentationScope scope
      }

withAttributes :: (Otel :> m) => Attributes -> Eff m a -> Eff m a
withAttributes attributes = localStaticRep modifyAttrubutes
  where
    modifyAttrubutes :: StaticRep Otel -> StaticRep Otel
    modifyAttrubutes otelState = otelState
      { globalAttributes = globalAttributes otelState <> attributes
      }

metrics :: Vector Metric -> Eff m ()
metrics = undefined

nanosSinceEpoch :: UTCTime -> Word64
nanosSinceEpoch = floor . (1e9 *) . nominalDiffTimeToSeconds . utcTimeToPOSIXSeconds

log :: (Otel :> m) => LogData -> Eff m ()
log LogData{..} = do
  otelState@OtelState{..} <- getStaticRep
  time <- unsafeEff_ getCurrentTime
  unsafeEff_ . sendLog $ mkLogRecord otelState time
  where
    mkLogRecord :: StaticRep Otel -> UTCTime -> LogRecord
    mkLogRecord OtelState{..} time = defMessage
      & #severityText .~ logLevelToSeverityText logLevel
      & #severityNumber .~ logLevelToSeverityNumber logLevel
      & #body .~ messageBody
      & #vec'attributes .~ (globalAttributes <> attributes)
      -- FIXME: What is the difference between traceId and spanId

      & #timeUnixNano .~ nanosSinceEpoch time
      & mkIds mTraceAndSpanIds

    mkIds :: Maybe (TraceId, SpanId) -> LogRecord -> LogRecord
    mkIds = \case
      Nothing -> id
      Just (traceId, spanId) ->
        (#traceId .~ fromTraceId traceId)
        . (#spanId .~ fromSpanId spanId)

    messageBody :: AnyValue
    messageBody = defMessage
      & #maybe'stringValue ?~ message


trace :: forall es a. (Otel :> es) => TraceData -> Eff es a -> Eff es a
trace TraceData{..} m = do
  OtelState{..} <- getStaticRep
  case mTraceAndSpanIds of
    -- Missing `traceId` means the tracing is disabled for this transaction.
    -- So the action is executed without changing the tracing scope and without
    -- doing tracing request.
    Nothing -> m
    Just (traceId, oldSpanId) -> do
      newSpanId <- unsafeEff_ getRandomSpanId
      startTime <- unsafeEff_ getCurrentTime

      (events', ret) <- localStaticRep (newTraceLayer (traceId, newSpanId)) appInNewLayer
      endTime <- unsafeEff_ getCurrentTime
      unsafeEff_ . sendTrace $ mkSpan globalAttributes startTime endTime oldSpanId traceId newSpanId events'
      pure ret
  where
    -- Each layer gets new `OtelState` with empty events. The collection of
    -- events is then returned, so they can be logged as part of the trace.
    appInNewLayer :: Eff es (Vector Span'Event, a)
    appInNewLayer = do
      ret <- m
      OtelState{..} <- getStaticRep
      pure (events, ret)


    mkSpan :: Attributes -> UTCTime -> UTCTime -> SpanId -> TraceId -> SpanId -> Vector Span'Event -> Span
    mkSpan globalAttrubutes startTime endTime oldSpanId traceId newSpanId events' = defMessage
      & #traceId .~ fromTraceId traceId
      & #spanId .~ fromSpanId newSpanId
      & #parentSpanId .~ fromSpanId oldSpanId
      & #name .~ name
      & #kind .~ toOtelSpanKind kind
      & #startTimeUnixNano .~ nanosSinceEpoch startTime
      & #endTimeUnixNano .~ nanosSinceEpoch endTime
      & #vec'attributes .~ (attributes <> globalAttrubutes)
      & #vec'events .~ events'
      & #vec'links .~ toOtelSpanLinks spanLinks
      -- FIXME: Think about adding correct span status here. Not sure what the
      -- error is for though.
      & #status .~ toOtelSpanStatus SpanOk

    -- The layers work like stack the top of the stack is current context that
    -- gets to be turned into a trace.
    newTraceLayer :: (TraceId, SpanId) -> StaticRep Otel -> StaticRep Otel
    newTraceLayer (traceId, newSpanId) otelState = otelState
      { mTraceAndSpanIds = Just (traceId, newSpanId)
      , events = mempty
      }
