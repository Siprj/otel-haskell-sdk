{-# LANGUAGE TypeFamilies #-}
module Otel.Effect
  ( Otel(..)
  , withInstrumentation
  , log
  , trace
  , metrics
  , getCurrentTraceId
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
import Data.ProtoLens (defMessage, fieldDefault)
import Data.Maybe
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
  GetCurrentTraceIdCall :: Otel m (Maybe TraceId)
  GetCurrentSpanIdCall :: Otel m (Maybe SpanId)

withInstrumentation :: (HasCallStack, Otel :> es ) => InstrumentationScope -> Eff es a -> Eff es a
withInstrumentation scope' m = send $ WithInstrumentationScopeCall scope' m

log :: (HasCallStack, Otel :> es ) => LogRecord -> Eff es ()
log logRecord' = send $ LogCall logRecord'

trace :: (HasCallStack, Otel :> es ) => Span -> Eff es ()
trace span' = send $ TraceCall span'

metrics :: (HasCallStack, Otel :> es ) => Vector Metric -> Eff es ()
metrics metric' = send $ MetricsCall metric'

getCurrentTraceId :: (HasCallStack, Otel :> es ) => Eff es (Maybe TraceId)
getCurrentTraceId = send GetCurrentTraceIdCall

getCurrentSpanId :: (HasCallStack, Otel :> es ) => Eff es (Maybe SpanId)
getCurrentSpanId = send GetCurrentSpanIdCall

log' :: (HasCallStack, Otel :> es, IOE :> es) => LogLevel -> Attributes -> Message -> Eff es ()
log' logLevel attributes message = do
  mTraceId <- getCurrentTraceId
  mSpanId <- getCurrentSpanId
  -- FIXME: Maybe time effect should be used instead of IO call???
  time <- liftIO getCurrentTime
  log $ mkLogRecord mTraceId mSpanId time
  where
    mkLogRecord :: Maybe TraceId -> Maybe SpanId -> UTCTime -> LogRecord
    mkLogRecord mTraceId mSpanId time = defMessage
      & #severityText .~ logLevelToSeverityText logLevel
      & #severityNumber .~ logLevelToSeverityNumber logLevel
      & #body .~ messageBody
      & #vec'attributes .~ attributes
      -- FIXME: What is the difference between traceId and spanId
      & #traceId .~ (fromMaybe fieldDefault mTraceId)
      & #spanId .~ (fromMaybe fieldDefault mSpanId)
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
logTrace_ message = logTrace emptyAttributes message

logDebug_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logDebug_ message = logDebug emptyAttributes message

logInfo_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logInfo_ message = logInfo emptyAttributes message

logWarn_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logWarn_ message = logWarn emptyAttributes message

logError_ :: (HasCallStack, Otel :> es, IOE :> es) => Message -> Eff es ()
logError_ message = logError emptyAttributes message

logFatal_ :: (HasCallStack, Otel :> es , IOE :> es) => Message -> Eff es ()
logFatal_ message = logFatal emptyAttributes message


-- Tracing --------------------------------------------------------------------

-- TODO: There was something about callstack that can be part of
-- traces??? Maybe in case of error status???
spanFromContextAndLinks
  :: (HasCallStack, Otel :> es , IOE :> es)
  => SpanContext
  -> SpanLinks
  -> SpanKind
  -> Attributes
  -> SpanName
  -> Eff es ()
spanFromContextAndLinks = undefined

spanAndLinks
  :: (HasCallStack, Otel :> es , IOE :> es)
  => SpanLinks
  -> Attributes
  -> SpanKind
  -> SpanName
  -> Eff es ()
spanAndLinks = undefined

span
  :: (HasCallStack, Otel :> es , IOE :> es)
  => Attributes
  -> SpanKind
  -> SpanName
  -> Eff es ()
span = spanAndLinks emptyLinks

span_
  :: (HasCallStack, Otel :> es , IOE :> es)
  => SpanKind
  -> SpanName
  -> Eff es ()
span_ = span emptyAttributes
