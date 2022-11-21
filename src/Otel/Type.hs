{-# LANGUAGE TypeFamilies #-}
module Otel.Type
  ( LogLevel(..)
  , Attributes
  , Message
  , ResourceAttributes
  , ScopeAttributes
  , Scope(..)
  , emptyAttributes
  , logLevelToSeverityText
  , logLevelToSeverityNumber
  , TraceId
  , SpanId
  , SpanName
  , SpanContext(..)
  , Sampled(..)
  , SpanLink(..)
  , SpanLinks
  , emptyLinks
  , SpanKind(..)
  )
where

import Data.Vector
import Data.Text hiding (empty)
import Proto.Opentelemetry.Proto.Common.V1.Common
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import GHC.Generics
import Data.ByteString hiding (pack, empty)

data LogLevel
  = Trace
  | Debug
  | Info
  | Warn
  | Error
  | Fatal
  deriving stock (Show, Generic)

logLevelToSeverityText :: LogLevel -> Text
logLevelToSeverityText = pack . show

logLevelToSeverityNumber :: LogLevel -> SeverityNumber
logLevelToSeverityNumber = \case
  Trace -> SEVERITY_NUMBER_TRACE
  Debug -> SEVERITY_NUMBER_DEBUG
  Info -> SEVERITY_NUMBER_INFO
  Warn -> SEVERITY_NUMBER_WARN
  Error -> SEVERITY_NUMBER_ERROR
  Fatal -> SEVERITY_NUMBER_FATAL

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
type TraceId = ByteString
type SpanId = ByteString

-- Describes the scope. Can be a component or instrumented library.
data Scope = Scope
  { name :: Text
  , version :: Text
  , attributes :: ScopeAttributes
  }
  deriving stock (Show, Generic)

emptyAttributes :: Attributes
emptyAttributes = empty

type SpanName = Text

data Sampled = Sampled | Unsampled

-- Context is used for propagating the trace across services
data SpanContext = SpanContext
  { traceId :: TraceId
  , parentSpanId :: SpanId
  , sampled :: Sampled
  , attributes :: Attributes
  }

-- FIXME: There should be a way to get link from currently running span.
data SpanLink = SpanLink
  { traceId :: TraceId
  , spanId :: SpanId
  , attributes :: Attributes
  }

type SpanLinks = Vector SpanLink

emptyLinks :: SpanLinks
emptyLinks = empty

data SpanKind
  = Unspecified
  | Internal
  | Server
  | Client
  | Producer
  | Consumer
