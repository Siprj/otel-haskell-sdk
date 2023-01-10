{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TypeFamilies #-}
module Lib
  ( greet
  )
where

import Data.ProtoLens
import Data.ProtoLens.Labels ()
import Lens.Micro
import Data.Text
import Proto.Opentelemetry.Proto.Common.V1.Common
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import Otel.Client
import Proto.Opentelemetry.Proto.Resource.V1.Resource (Resource)
import Control.Concurrent.STM
import Control.Monad
import Control.Concurrent (threadDelay)

greet :: IO ()
greet = do
  otelClient <- createOtelClient defautOtelClientParameters
  forever $ sendData otelClient
  where
    sendData :: OtelClient -> IO ()
    sendData OtelClient{..} = do
      threadDelay 1
      atomically $ writeTBQueue queueLogs otelResourceLogs

    otelResourceLogs :: ResourceLogs
    otelResourceLogs = defMessage
      & #scopeLogs .~ otelScopedLogs
      & #resource .~ otelResource

    otelResource :: Resource
    otelResource = defMessage
      & #attributes .~ resourceAttributes

    resourceAttributes :: [KeyValue]
    resourceAttributes =
      [ defMessage & #key .~ "machine" & #value .~
        ( defMessage & #kvlistValue .~
          (defMessage & #values .~
            [defMessage & #key .~ "name" & #value .~ (defMessage & #stringValue .~ "machine-name")
            ]
          )
        )
      , defMessage & #key .~ "machine.id" & #value .~ (defMessage & #maybe'stringValue ?~ "123")
      , defMessage & #key .~ "container_name" & #value .~ (defMessage & #maybe'stringValue ?~ "blabla container")
      ]

    otelScopedLogs :: [ScopeLogs]
    otelScopedLogs =
      [ defMessage & #scope .~ instrScope & #logRecords .~ [logRecord]
      , defMessage & #scope .~ instrScope & #logRecords .~ [logRecord]
      ]

    instrScope :: InstrumentationScope
    instrScope = defMessage
      & #name .~ "super nice scope 1"
      & #version .~ "0.0.1"
      & #attributes .~ scopeAttributes

    scopeAttributes :: [KeyValue]
    scopeAttributes =
      [ defMessage & #key .~ "nice.scope.attibute1" & #value .~ (defMessage & #maybe'stringValue ?~ "attribute1")
      , defMessage & #key .~ "nice.scope.attibute2" & #value .~ (defMessage & #maybe'stringValue ?~ "attribute2")
      , defMessage & #key .~ "source" & #value .~ (defMessage & #maybe'stringValue ?~ "super source")
      ]

    logRecord :: LogRecord
    logRecord = defMessage
      & #severityText .~ ("INFO" :: Text)
      & #body .~ messageBody

    messageBody :: AnyValue
    messageBody = defMessage
      & #maybe'stringValue ?~ "asdfa sdfasdfasdf"
