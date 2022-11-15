{-# LANGUAGE TypeFamilies #-}
module Otel.Effect
  ( Otel(..)
  , withInstrumentation
  , log
  , trace
  , metrics
  )
where

import Prelude hiding (log)

import Effectful
import Proto.Opentelemetry.Proto.Common.V1.Common
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import Proto.Opentelemetry.Proto.Trace.V1.Trace
import Data.Vector
import Proto.Opentelemetry.Proto.Metrics.V1.Metrics
import GHC.Stack
import Effectful.Dispatch.Dynamic



type instance DispatchOf Otel = 'Dynamic

data Otel :: Effect where
  WithInstrumentationScope :: InstrumentationScope -> m a -> Otel m a
  Log :: LogRecord -> Otel m ()
  Trace :: Span -> Otel m ()
  Metrics :: (Vector Metric) -> Otel m ()

withInstrumentation :: (HasCallStack, Otel :> es ) => InstrumentationScope -> Eff es a -> Eff es a
withInstrumentation scope' m = send $ WithInstrumentationScope scope' m

log :: (HasCallStack, Otel :> es ) => LogRecord -> Eff es ()
log logRecord' = send $ Log logRecord'

trace :: (HasCallStack, Otel :> es ) => Span -> Eff es ()
trace span' = send $ Trace span'

metrics :: (HasCallStack, Otel :> es ) => Vector Metric -> Eff es ()
metrics metric' = send $ Metrics metric'
