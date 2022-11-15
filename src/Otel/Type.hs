{-# LANGUAGE TypeFamilies #-}
module Otel.Type
  ( LogLevel(..)
  , logDebug
  , logError
  , logFatal
  , logInfo
  , logTrace
  , logWarn
  , logDebug_
  , logError_
  , logFatal_
  , logInfo_
  , logTrace_
  , logWarn_
  )
where

import Data.Vector
import Data.Text
import Proto.Opentelemetry.Proto.Common.V1.Common
import GHC.Generics

data LogLevel
  = Trace
  | Debug
  | Info
  | Warn
  | Error
  | Fatal

type Attributes = Vector KeyValue
type Message = Text

-- Describe the resource on which the code is running on. For example it can be
-- some thing like:
--  * Docker id
--  * Docker container name
--  * Host name
--  * Machine IP address
--  * Cluster ID/Name
--  Or basically it can be anything else that can be considered to be a
--  description of the running resource.
type ResourceAttributes = Attributes

type ScopeAttributes = Attributes

-- Describes the scope. Can be a component or instrumented library.
data Scope = Scope
  { name :: Text
  , version :: Text
  , attributes :: ScopeAttributes
  }
  deriving stock (Show, Generic)

-- TODO: This needs to be moved somewhere else and renamed
logMessage :: ResourceAttributes -> LogLevel -> Message -> Attributes -> IO ()
logMessage = undefined

logTrace :: ResourceAttributes -> Message -> Attributes -> IO ()
logTrace resourceAttributes = logMessage resourceAttributes Trace

logDebug :: ResourceAttributes -> Message -> Attributes -> IO ()
logDebug resourceAttributes = logMessage resourceAttributes Trace

logInfo :: ResourceAttributes -> Message -> Attributes -> IO ()
logInfo resourceAttributes = logMessage resourceAttributes Info

logWarn :: ResourceAttributes -> Message -> Attributes -> IO ()
logWarn resourceAttributes = logMessage resourceAttributes Warn

logError :: ResourceAttributes -> Message -> Attributes -> IO ()
logError resourceAttributes = logMessage resourceAttributes Error

logFatal :: ResourceAttributes -> Message -> Attributes -> IO ()
logFatal resourceAttributes = logMessage resourceAttributes Fatal

emptyAttributes :: Attributes
emptyAttributes = undefined

logTrace_ :: ResourceAttributes -> Message -> IO ()
logTrace_ resourceAttributes message = logTrace resourceAttributes message emptyAttributes

logDebug_ :: ResourceAttributes -> Message -> IO ()
logDebug_ resourceAttributes message = logDebug resourceAttributes message emptyAttributes

logInfo_ :: ResourceAttributes -> Message -> IO ()
logInfo_ resourceAttributes message = logInfo resourceAttributes message emptyAttributes

logWarn_ :: ResourceAttributes -> Message -> IO ()
logWarn_ resourceAttributes message = logWarn resourceAttributes message emptyAttributes

logError_ :: ResourceAttributes -> Message -> IO ()
logError_ resourceAttributes message = logError resourceAttributes message emptyAttributes

logFatal_ :: ResourceAttributes -> Message -> IO ()
logFatal_ resourceAttributes message = logFatal resourceAttributes message emptyAttributes


