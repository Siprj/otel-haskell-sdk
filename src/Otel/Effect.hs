{-# LANGUAGE TypeFamilies #-}
module Otel.Effect
  ( Otel(..)
  , withInstrumentation
  , log
  , trace
  , metrics
  , getCurrentTraceId
  , getCurrentSpanId
  , setCurrentTraceId
  , setCurrentSpanId
  , logTrace
  , logDebug
  , logInfo
  , logWarn
  , logError
  , logFatal
  , logTrace_
  , logDebug_
  , logInfo_
  , logWarn_
  , logError_
  , logFatal_
  , spanFromContextAndLinks
  , spanAndLinks
  , span
  , span_
  )
where

import Prelude hiding (log, span)

import Effectful
import Proto.Opentelemetry.Proto.Common.V1.Common
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import Proto.Opentelemetry.Proto.Trace.V1.Trace
import Data.Vector hiding (span)
import Proto.Opentelemetry.Proto.Metrics.V1.Metrics
import GHC.Stack
import Data.ProtoLens.Labels ()
import Effectful.Dispatch.Dynamic
import Otel.Type
import Lens.Micro
import Data.ProtoLens (defMessage)
import Data.Time.Clock.POSIX
import Data.Time.Clock
import Data.Word

nanosSinceEpoch :: UTCTime -> Word64
nanosSinceEpoch = floor . (1e9 *) . nominalDiffTimeToSeconds . utcTimeToPOSIXSeconds

type instance DispatchOf Otel = 'Dynamic


-- Root span should be created by the run effect function...
data Otel :: Effect where
  WithInstrumentationScopeCall :: InstrumentationScope -> m a -> Otel m a
  LogCall :: LogRecord -> Otel m ()
  TraceCall :: Span -> Otel m ()
  MetricsCall :: (Vector Metric) -> Otel m ()
  GetCurrentTraceIdCall :: Otel m TraceId
  GetCurrentSpanIdCall :: Otel m SpanId
  SetCurrentTraceIdCall :: TraceId -> Otel m ()
  SetCurrentSpanIdCall :: SpanId -> Otel m ()

withInstrumentation :: (HasCallStack, Otel :> es ) => InstrumentationScope -> Eff es a -> Eff es a
withInstrumentation scope' m = send $ WithInstrumentationScopeCall scope' m

log :: (HasCallStack, Otel :> es ) => LogRecord -> Eff es ()
log logRecord' = send $ LogCall logRecord'

trace :: (HasCallStack, Otel :> es ) => Span -> Eff es ()
trace span' = send $ TraceCall span'

metrics :: (HasCallStack, Otel :> es ) => Vector Metric -> Eff es ()
metrics metric' = send $ MetricsCall metric'

getCurrentTraceId :: (HasCallStack, Otel :> es ) => Eff es TraceId
getCurrentTraceId = send GetCurrentTraceIdCall

getCurrentSpanId :: (HasCallStack, Otel :> es ) => Eff es SpanId
getCurrentSpanId = send GetCurrentSpanIdCall

setCurrentTraceId :: (HasCallStack, Otel :> es ) => TraceId -> Eff es ()
setCurrentTraceId = send . SetCurrentTraceIdCall

setCurrentSpanId :: (HasCallStack, Otel :> es ) => SpanId -> Eff es ()
setCurrentSpanId = send . SetCurrentSpanIdCall

log' :: (HasCallStack, Otel :> es, IOE :> es) => LogLevel -> Attributes -> Message -> Eff es ()
log' logLevel attributes message = do
  traceId <- getCurrentTraceId
  spanId <- getCurrentSpanId
  -- FIXME: Maybe time effect should be used instead of IO call???
  time <- liftIO getCurrentTime
  log $ mkLogRecord traceId spanId time
  where
    mkLogRecord :: TraceId -> SpanId -> UTCTime -> LogRecord
    mkLogRecord traceId spanId time = defMessage
      & #severityText .~ logLevelToSeverityText logLevel
      & #severityNumber .~ logLevelToSeverityNumber logLevel
      & #body .~ messageBody
      & #vec'attributes .~ attributes
      -- FIXME: What is the difference between traceId and spanId
      & #traceId .~ fromTraceId traceId
      & #spanId .~ fromSpanId spanId
      & #timeUnixNano .~ nanosSinceEpoch time

    messageBody :: AnyValue
    messageBody = defMessage
      & #maybe'stringValue ?~ message

logTrace :: (HasCallStack, Otel :> es, IOE :> es) => Attributes -> Message -> Eff es ()
logTrace = log' Trace

logDebug :: (HasCallStack, Otel :> es, IOE :> es) => Attributes -> Message -> Eff es ()
logDebug = log' Debug

logInfo :: (HasCallStack, Otel :> es, IOE :> es) => Attributes -> Message -> Eff es ()
logInfo = log' Info

logWarn :: (HasCallStack, Otel :> es, IOE :> es) => Attributes -> Message -> Eff es ()
logWarn = log' Warn

logError :: (HasCallStack, Otel :> es, IOE :> es) => Attributes -> Message -> Eff es ()
logError = log' Error

logFatal :: (HasCallStack, Otel :> es, IOE :> es) => Attributes -> Message -> Eff es ()
logFatal = log' Fatal

logTrace_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logTrace_ = logTrace emptyAttributes

logDebug_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logDebug_ = logDebug emptyAttributes

logInfo_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logInfo_ = logInfo emptyAttributes

logWarn_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logWarn_ = logWarn emptyAttributes

logError_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logError_ = logError emptyAttributes

logFatal_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logFatal_ = logFatal emptyAttributes


-- Tracing --------------------------------------------------------------------

-- TODO: There was something about callstack that can be part of
-- traces??? Maybe in case of error status???
spanFromContextAndLinks
  :: (HasCallStack, Otel :> es, IOE :> es)
  => SpanContext
  -> SpanLinks
  -> SpanKind
  -> Attributes
  -> SpanName
  -> Eff es ()
spanFromContextAndLinks = undefined

-- TODO: We are ignoring TraceState which should be part of Context
-- FIXME: I forgot about the actions that are supposed to measured by the trace.
spanAndLinks
  :: (HasCallStack, Otel :> es, IOE :> es)
  => SpanLinks
  -> Attributes
  -> SpanKind
  -> SpanName
  -> Eff es ()
spanAndLinks spanLinks attributes kind name = do
  time <- liftIO getCurrentTime
  traceId <- getCurrentTraceId
  oldSpanId <- getCurrentSpanId
  newSpanId <- liftIO getRandomSpanId
  trace $ mkSpan time oldSpanId traceId newSpanId
  where
    mkSpan :: UTCTime -> SpanId -> TraceId -> SpanId -> Span
    mkSpan time oldSpanId traceId newSpanId = defMessage
      & #traceId .~ fromTraceId traceId
      & #spanId .~ fromSpanId newSpanId
      & #parentSpanId .~ fromSpanId oldSpanId
      & #name .~ name
      & #kind .~ toOtelSpanKind kind
      & #startTimeUnixNano .~ nanosSinceEpoch time
      -- FIXME: end time needs to be implemented for the trace to work correctly
      -- & endTimeUnixNano
      & #vec'attributes .~ attributes
      -- FIXME: Not sure how to implement the events yet. Need to somehow share
      -- the correct span in the make event call :thinkface:. Maybe some kind
      -- of stack would do the trick???
      -- & #vec'events .~ something
      & #vec'links .~ toOtelSpanLinks spanLinks
      -- FIXME: Think about adding correct span status here. Not sure what the
      -- error is for though.
      & #status .~ toOtelSpanStatus SpanOk


span
  :: (HasCallStack, Otel :> es, IOE :> es)
  => Attributes
  -> SpanKind
  -> SpanName
  -> Eff es ()
span = spanAndLinks emptyLinks

span_
  :: (HasCallStack, Otel :> es, IOE :> es)
  => SpanKind
  -> SpanName
  -> Eff es ()
span_ = span emptyAttributes
