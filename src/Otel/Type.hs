{-# LANGUAGE TypeFamilies #-}
module Otel.Type
  ( LogLevel(..)
  , LogData(..)
  , TraceData(..)
  , Attributes
  , Message
  , ResourceAttributes
  , ScopeAttributes
  , Scope(..)
  , toOtelInstrumentationScope
  , emptyAttributes
  , logLevelToSeverityText
  , logLevelToSeverityNumber
  , TraceId
  , getRandomTraceId
  , fromTraceId
  , SpanId
  , getRandomSpanId
  , fromSpanId
  , SpanName
  , SpanContext(..)
  , Sampled(..)
  , SpanLink(..)
  , toOtelSpanLink
  , SpanLinks
  , toOtelSpanLinks
  , emptyLinks
  , SpanKind(..)
  , toOtelSpanKind
  , SpanStatus(..)
  , toOtelSpanStatus
  )
where

import Data.Vector
import Data.Text hiding (empty)
import Proto.Opentelemetry.Proto.Common.V1.Common
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import GHC.Generics
import Data.ByteString hiding (pack, empty)
import GHC.Num (Natural)
import System.Random
import System.Random.Stateful
import Proto.Opentelemetry.Proto.Trace.V1.Trace (Span'SpanKind (..), Span'Link, Status, Status'StatusCode (..))
import Data.ProtoLens (defMessage)
import Lens.Micro ((&), (.~))
import Data.ProtoLens.Labels ()

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
newtype TraceId = TraceId ByteString
  deriving stock (Show, Generic)
newtype SpanId = SpanId ByteString
  deriving stock (Show, Generic)

getRandomTraceId :: IO TraceId
getRandomTraceId = TraceId <$> getRandomID 16

fromTraceId :: TraceId -> ByteString
fromTraceId (TraceId traceId) = traceId

getRandomSpanId :: IO SpanId
getRandomSpanId = SpanId <$> getRandomID 8

fromSpanId :: SpanId -> ByteString
fromSpanId (SpanId spanId) = spanId

getRandomID :: Natural -> IO ByteString
getRandomID size = applyAtomicGen (genByteString $ fromIntegral size) globalStdGen

-- Describes the scope. Can be a component or instrumented library.
data Scope = Scope
  { name :: Text
  , version :: Text
  , attributes :: ScopeAttributes
  }
  deriving stock (Show, Generic)

toOtelInstrumentationScope :: Scope -> InstrumentationScope
toOtelInstrumentationScope Scope{..} = defMessage
  & #name .~ name
  & #version .~ version
  -- TODO: Think about addint trace state here...
  & #vec'attributes .~ attributes

emptyAttributes :: Attributes
emptyAttributes = empty

type SpanName = Text

data Sampled = Sampled | Unsampled
  deriving stock (Show, Generic)

-- Context is used for propagating the trace across services
data SpanContext = SpanContext
  { traceId :: TraceId
  , parentSpanId :: SpanId
  , sampled :: Sampled
  , attributes :: Attributes
  }
  deriving stock (Show, Generic)

-- FIXME: There should be a way to get link from currently running span.
data SpanLink = SpanLink
  { traceId :: TraceId
  , spanId :: SpanId
  , attributes :: Attributes
  }
  deriving stock (Show, Generic)

toOtelSpanLink :: SpanLink -> Span'Link
toOtelSpanLink SpanLink{..} = defMessage
  & #traceId .~ fromTraceId traceId
  & #spanId .~ fromSpanId spanId
  -- TODO: Think about addint trace state here...
  & #vec'attributes .~ attributes

type SpanLinks = Vector SpanLink

toOtelSpanLinks :: SpanLinks -> Vector Span'Link
toOtelSpanLinks = fmap toOtelSpanLink

emptyLinks :: SpanLinks
emptyLinks = empty

data SpanKind
  = Unspecified
  | Internal
  | Server
  | Client
  | Producer
  | Consumer
  deriving stock (Show, Generic)

toOtelSpanKind :: SpanKind -> Span'SpanKind
toOtelSpanKind = \case
    Unspecified -> Span'SPAN_KIND_UNSPECIFIED
    Internal -> Span'SPAN_KIND_INTERNAL
    Server -> Span'SPAN_KIND_SERVER
    Client -> Span'SPAN_KIND_CLIENT
    Producer -> Span'SPAN_KIND_PRODUCER
    Consumer -> Span'SPAN_KIND_CONSUMER

-- Error is human readable error text
data SpanStatus = SpanOk | SpanError Text

toOtelSpanStatus :: SpanStatus -> Status
toOtelSpanStatus SpanOk = defMessage
  & #code .~ Status'STATUS_CODE_OK
toOtelSpanStatus (SpanError errorMessage) = defMessage
  & #code .~ Status'STATUS_CODE_ERROR
  & #message .~ errorMessage


data LogData = LogData
  { logLevel :: !LogLevel
  , message :: !Text
  , attributes :: !Attributes
  }
  deriving stock (Show, Generic)

data TraceData = TraceData
  { name :: !Text
  , kind :: !SpanKind
  , attributes :: !Attributes
  , spanLinks :: !(Vector SpanLink)
  }
  deriving stock (Show, Generic)

data Event = Event
  { name :: !Text
  , attributes :: !Attributes
  }
  deriving stock (Show, Generic)
