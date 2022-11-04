{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TypeFamilies #-}
module Lib
  ( greet
  )
where

import Network.HTTP.Client
import Data.ProtoLens
import Data.ProtoLens.Labels ()
import Lens.Micro
import Data.Text
import Proto.Opentelemetry.Proto.Common.V1.Common
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import Proto.Opentelemetry.Proto.Metrics.V1.Metrics
import Proto.Opentelemetry.Proto.Trace.V1.Trace
import Effectful
import Data.Vector
import GHC.Stack (HasCallStack)
import Effectful.Dispatch.Dynamic

type instance DispatchOf Otel = Dynamic
data Otel :: Effect where
  WithScope :: InstrumentationScope -> m a -> Otel m a
  Log :: LogRecord -> Otel m ()
  Trace :: Span -> Otel m ()
  Metrics :: (Vector Metric) -> Otel m ()

withInstrumentation :: (HasCallStack, Otel :> es ) => InstrumentationScope -> Eff es a -> Eff es a
withInstrumentation scope' m = send $ WithScope scope' m

log :: (HasCallStack, Otel :> es ) => LogRecord -> Eff es ()
log logRecord' = send $ Log logRecord'

trace :: (HasCallStack, Otel :> es ) => Span -> Eff es ()
trace span' = send $ Trace span'

metrics :: (HasCallStack, Otel :> es ) => Vector Metric -> Eff es ()
metrics metric' = send $ Metrics metric'

greet :: IO ()
greet = do
  manager <- newManager defaultManagerSettings
  initilaRequest <- parseRequest "http://localhost:4218/v1/logs"
  print $ showMessage message
  print $ encodeMessage message
  let request = initilaRequest { method = "POST", requestHeaders = [("Content-Type", "application/x-protobuf")], requestBody = RequestBodyBS $ encodeMessage message }
  httpLbs request manager >>= print

  putStrLn "asdfasdf"
  where
    message :: LogRecord
    message = defMessage
      & #severityText .~ ("INFO" :: Text)
      & #traceId .~ "112313"
      & #body .~ messageBody

    messageBody :: AnyValue
    messageBody = defMessage
      & #maybe'stringValue ?~ "asdfa sdfasdfasdf"
