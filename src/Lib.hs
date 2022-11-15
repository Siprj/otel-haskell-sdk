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
