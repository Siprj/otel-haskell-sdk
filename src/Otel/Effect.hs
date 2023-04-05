{-# LANGUAGE TypeFamilies #-}

module Otel.Effect (
  Otel (..),
  runOtel,
  withInstrumentationScope,
  withAttributes,
  log,
  traceSpan,
  metrics,
  logTrace,
  logDebug,
  logInfo,
  logWarn,
  logError,
  logFatal,
  logTrace_,
  logDebug_,
  logInfo_,
  logWarn_,
  logError_,
  logFatal_,
  traceEvent,
  traceUnspecified,
  traceInternal,
  traceServer,
  traceClient,
  traceProducer,
  traceConsumer,
  traceUnspecified_,
  traceInternal_,
  traceServer_,
  traceClient_,
  traceProducer_,
  traceConsumer_,
  spanLink,
) where

import Data.ProtoLens.Labels ()
import Data.Text (Text)
import Data.Vector hiding (span)
import Effectful
import Effectful.Dispatch.Dynamic
import GHC.TypeLits (KnownSymbol)
import Otel.Client (OtelClient)
import Otel.Effect.Static qualified as S
import Otel.Internal.Type
import Proto.Opentelemetry.Proto.Metrics.V1.Metrics
import Prelude hiding (log, span)

type instance DispatchOf Otel = 'Dynamic

-- | Dynamic `Otel` effect, is is recommended to use this one compare to the
-- static effect.
data Otel :: Effect where
  WithInstrumentationScopeCall ::
    (KnownSymbol name, KnownSymbol version) =>
    Scope name version ->
    m a ->
    Otel m a
  WithAtributesCall :: Attributes -> m a -> Otel m a
  MetricsCall :: (Vector Metric) -> Otel m ()
  LogCall :: LogData -> Otel m ()
  TraceSpanCall :: TraceData -> m a -> Otel m a
  TraceEventCall :: TraceEvent -> Otel m ()
  SpanLinCall :: Otel m (Maybe SpanLink)

-- | Run the dynamic effect and create the root trace if the trace data are
-- provided. If the trace data is not provided any subsequent trace call will
-- be ignored.
--
-- This function has to finish for the root trace to be sent.
runOtel ::
  (IOE :> es) => OtelClient -> Maybe TraceData -> Eff (Otel : es) a -> Eff es a
runOtel otelClient mRootTraceData =
  reinterpret (S.runOtelStatic otelClient mRootTraceData) localOtel

localOtel ::
  (S.Otel :> es) =>
  LocalEnv localEs es ->
  Otel (Eff localEs) a ->
  Eff es a
localOtel env = \case
  WithInstrumentationScopeCall typeScope m ->
    localSeqUnlift env $
      \unlift -> S.withInstrumentationScope typeScope (unlift m)
  WithAtributesCall attributes m ->
    localSeqUnlift env $ \unlift -> S.withAttributes attributes (unlift m)
  MetricsCall metrics' -> S.metrics metrics'
  LogCall logData -> S.log logData
  TraceSpanCall traceData m ->
    localSeqUnlift env $ \unlift -> S.traceSpan traceData (unlift m)
  TraceEventCall eventData -> S.traceEvent eventData
  SpanLinCall -> S.spanLink

-- | Change the instrumentation scope. This function should be used by
-- instrumented/instrumentation libraries/components to indicate the
-- library/component name and version.
withInstrumentationScope ::
  (HasCallStack, KnownSymbol name, KnownSymbol version, Otel :> es) =>
  Scope name version ->
  Eff es a ->
  Eff es a
withInstrumentationScope scope' m = send $ WithInstrumentationScopeCall scope' m

-- | Allows to add attributes to subsequent calls of log/trace/metric functions.
-- Attribute name should be in 'abc.def.ghi` format, and they have to be unique
-- across the whole trace or they will be rewritten.
withAttributes :: (HasCallStack, Otel :> m) => Attributes -> Eff m a -> Eff m a
withAttributes attributes m = send $ WithAtributesCall attributes m

-- | The most general logging function.
log :: (HasCallStack, Otel :> es) => LogData -> Eff es ()
log logData = send $ LogCall logData

-- | The most general tracing function.
traceSpan :: (HasCallStack, Otel :> es) => TraceData -> Eff es a -> Eff es a
traceSpan traceData m = send $ TraceSpanCall traceData m

-- | Otel traces allow to add significant events into the trace trace
-- directly. The difference with logs is that logs are only linked to traces,
-- but the events are embedded in traces. This also means that when traces
-- are disabled the events will not be collected.
traceEvent :: (HasCallStack, Otel :> es) => Text -> Attributes -> Eff es ()
traceEvent name attributes = send . TraceEventCall $ TraceEvent {..}

-- | !!!NOT DONE!!!
metrics :: (HasCallStack, Otel :> es) => Vector Metric -> Eff es ()
metrics metric' = send $ MetricsCall metric'

log' :: (HasCallStack, Otel :> es) => LogLevel -> Attributes -> Text -> Eff es ()
log' logLevel attributes message = log LogData {..}

-- | Version of the log function with log level `Trace`.
logTrace :: (HasCallStack, Otel :> es) => Attributes -> Text -> Eff es ()
logTrace = log' Trace

-- | Version of the log function with log level `Debug`.
logDebug :: (HasCallStack, Otel :> es) => Attributes -> Text -> Eff es ()
logDebug = log' Debug

-- | Version of the log function with log level `Info`.
logInfo :: (HasCallStack, Otel :> es) => Attributes -> Text -> Eff es ()
logInfo = log' Info

-- | Version of the log function with log level `Warn`.
logWarn :: (HasCallStack, Otel :> es) => Attributes -> Text -> Eff es ()
logWarn = log' Warn

-- | Version of the log function with log level `Error`.
logError :: (HasCallStack, Otel :> es) => Attributes -> Text -> Eff es ()
logError = log' Error

-- | Version of the log function with log level `Fatal`.
logFatal :: (HasCallStack, Otel :> es) => Attributes -> Text -> Eff es ()
logFatal = log' Fatal

-- | Version of the log function with log level `Trace` and  empty
-- attributes.
logTrace_ :: (HasCallStack, Otel :> es) => Text -> Eff es ()
logTrace_ = logTrace mempty

-- | Version of the log function with log level `Debug` and  empty
-- attributes.
logDebug_ :: (HasCallStack, Otel :> es) => Text -> Eff es ()
logDebug_ = logDebug mempty

-- | Version of the log function with log level `Info` and  empty
-- attributes.
logInfo_ :: (HasCallStack, Otel :> es) => Text -> Eff es ()
logInfo_ = logInfo mempty

-- | Version of the log function with log level `Warn` and  empty
-- attributes.
logWarn_ :: (HasCallStack, Otel :> es) => Text -> Eff es ()
logWarn_ = logWarn mempty

-- | Version of the log function with log level `Error` and  empty
-- attributes.
logError_ :: (HasCallStack, Otel :> es) => Text -> Eff es ()
logError_ = logError mempty

-- | Version of the log function with log level `Fatal` and  empty
-- attributes.
logFatal_ :: (HasCallStack, Otel :> es) => Text -> Eff es ()
logFatal_ = logFatal mempty

traceSpan' ::
  (HasCallStack, Otel :> es) =>
  SpanKind ->
  Text ->
  Attributes ->
  SpanLinks ->
  Eff es a ->
  Eff es a
traceSpan' kind name attributes spanLinks = traceSpan TraceData {..}

-- | Version of the `traceSpan` function with kind as `Unspecified`.
traceUnspecified ::
  (HasCallStack, Otel :> es) =>
  Text ->
  Attributes ->
  SpanLinks ->
  Eff es a ->
  Eff es a
traceUnspecified = traceSpan' Unspecified

-- | Version of the `traceSpan` function with kind as `Internal`.
traceInternal ::
  (HasCallStack, Otel :> es) =>
  Text ->
  Attributes ->
  SpanLinks ->
  Eff es a ->
  Eff es a
traceInternal = traceSpan' Internal

-- | Version of the `traceSpan` function with kind as `Server`.
traceServer ::
  (HasCallStack, Otel :> es) =>
  Text ->
  Attributes ->
  SpanLinks ->
  Eff es a ->
  Eff es a
traceServer = traceSpan' Server

-- | Version of the `traceSpan` function with kind as `Client`.
traceClient ::
  (HasCallStack, Otel :> es) =>
  Text ->
  Attributes ->
  SpanLinks ->
  Eff es a ->
  Eff es a
traceClient = traceSpan' Client

-- | Version of the `traceSpan` function with kind as `Producer`.
traceProducer ::
  (HasCallStack, Otel :> es) =>
  Text ->
  Attributes ->
  SpanLinks ->
  Eff es a ->
  Eff es a
traceProducer = traceSpan' Producer

-- | Version of the `traceSpan` function with kind as `Consumer`.
traceConsumer ::
  (HasCallStack, Otel :> es) =>
  Text ->
  Attributes ->
  SpanLinks ->
  Eff es a ->
  Eff es a
traceConsumer = traceSpan' Consumer

-- | Version of the `traceSpan` function with kind as `Unspecified`, and
-- without the attributes and span links.
traceUnspecified_ :: (HasCallStack, Otel :> es) => Text -> Eff es a -> Eff es a
traceUnspecified_ name = traceUnspecified name mempty mempty

-- | Version of the `traceSpan` function with kind as `Internal`, and without
-- the attributes and span links.
traceInternal_ :: (HasCallStack, Otel :> es) => Text -> Eff es a -> Eff es a
traceInternal_ name = traceInternal name mempty mempty

-- | Version of the `traceSpan` function with kind as `Server`, and without the
-- attributes and span links.
traceServer_ :: (HasCallStack, Otel :> es) => Text -> Eff es a -> Eff es a
traceServer_ name = traceServer name mempty mempty

-- | Version of the `traceSpan` function with kind as `Client`, and without the
-- attributes and span links.
traceClient_ :: (HasCallStack, Otel :> es) => Text -> Eff es a -> Eff es a
traceClient_ name = traceClient name mempty mempty

-- | Version of the `traceSpan` function with kind as `Client`, and without the
-- attributes and span links.
traceProducer_ :: (HasCallStack, Otel :> es) => Text -> Eff es a -> Eff es a
traceProducer_ name = traceProducer name mempty mempty

-- | Version of the `traceSpan` function with kind as `Consumer`, and without the
-- attributes and span links.
traceConsumer_ :: (HasCallStack, Otel :> es) => Text -> Eff es a -> Eff es a
traceConsumer_ name = traceConsumer name mempty mempty

-- | Faction for fetching links to the current spans/traces. This enables
-- developers to link, for example, cron jobs to the originating request that
-- triggered the cron job.
spanLink :: (HasCallStack, Otel :> es) => Eff es (Maybe SpanLink)
spanLink = send SpanLinCall
