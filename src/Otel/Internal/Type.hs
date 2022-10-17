{-# LANGUAGE TypeFamilies #-}

module Otel.Internal.Type (
  LogLevel (..),
  LogData (..),
  TraceData (..),
  Attributes,
  Value (..),
  toOtelValue,
  KeyValue (..),
  toOtelKeyValue,
  toOtelAttributes,
  ResourceAttributes,
  ScopeData (..),
  toOtelInstrumentationScope,
  logLevelToSeverityText,
  logLevelToSeverityNumber,
  TraceId,
  getRandomTraceId,
  fromTraceId,
  SpanId,
  getRandomSpanId,
  fromSpanId,
  SpanLink (..),
  toOtelSpanLink,
  SpanLinks,
  toOtelSpanLinks,
  SpanKind (..),
  toOtelSpanKind,
  SpanStatus (..),
  toOtelSpanStatus,
  Scope (Scope),
  toScopeData,
  TraceEvent (..),
) where

import Data.ByteString hiding (empty, pack)
import Data.Data (Proxy (Proxy))
import Data.Int (Int64)
import Data.ProtoLens (defMessage)
import Data.ProtoLens.Labels ()
import Data.Text hiding (empty)
import Data.Vector
import GHC.Base
import GHC.Generics
import GHC.TypeLits
import Lens.Micro ((&), (.~))
import Proto.Opentelemetry.Proto.Common.V1.Common hiding (KeyValue)
import Proto.Opentelemetry.Proto.Common.V1.Common qualified as C
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import Proto.Opentelemetry.Proto.Trace.V1.Trace (Span'Link, Span'SpanKind (..), Status, Status'StatusCode (..))
import System.Random
import System.Random.Stateful

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

data Value
  = StringV !Text
  | BoolV !Bool
  | IntV !Int64
  | DoubleV !Double
  | ArrayV ![Value]
  | KvlistV ![KeyValue]
  | BytesV !ByteString
  deriving stock (Show, Generic, Eq, Ord)

toOtelValue :: Value -> C.AnyValue
toOtelValue = \case
  StringV v -> defMessage & #stringValue .~ v
  BoolV v -> defMessage & #boolValue .~ v
  IntV v -> defMessage & #intValue .~ v
  DoubleV v -> defMessage & #doubleValue .~ v
  ArrayV v -> defMessage & #arrayValue .~ (defMessage & #values .~ fmap toOtelValue v)
  KvlistV v -> defMessage & #kvlistValue .~ (defMessage & #values .~ fmap toOtelKeyValue v)
  BytesV v -> defMessage & #bytesValue .~ v

data KeyValue = KeyValue {key :: Text, value :: Value}
  deriving stock (Show, Generic, Eq, Ord)

toOtelKeyValue :: KeyValue -> C.KeyValue
toOtelKeyValue KeyValue {..} = defMessage & #key .~ key & #value .~ toOtelValue value

type Attributes = [KeyValue]

toOtelAttributes :: Attributes -> Vector C.KeyValue
toOtelAttributes = fromList . fmap toOtelKeyValue

-- | Describe the resource on which the code is running on. For example it can be
-- some thing like:
--
--  * Docker id
--  * Docker container name
--  * Host name
--  * Machine IP address
--  * Cluster ID/Name
--
--  Or basically it can be anything else that can be considered to be a
--  description of the running resource.
type ResourceAttributes = Attributes

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

data Scope (name :: Symbol) (version :: Symbol) = Scope

-- Describes the scope. Can be a component or instrumented library.
data ScopeData = ScopeData
  { name :: Text
  , version :: Text
  }
  deriving stock (Show, Generic, Eq, Ord)

toScopeData ::
  forall name version.
  (KnownSymbol name, KnownSymbol version) =>
  Scope name version ->
  ScopeData
toScopeData _ =
  ScopeData
    { name = pack $ symbolVal (Proxy @name)
    , version = pack $ symbolVal (Proxy @version)
    }

toOtelInstrumentationScope :: ScopeData -> InstrumentationScope
toOtelInstrumentationScope ScopeData {..} =
  defMessage
    & #name .~ name
    & #version .~ version

data SpanLink = SpanLink
  { traceId :: TraceId
  , spanId :: SpanId
  , attributes :: Attributes
  }
  deriving stock (Show, Generic)

-- Trace state was omitted, because it was deemed unnecessary for now.
toOtelSpanLink :: SpanLink -> Span'Link
toOtelSpanLink SpanLink {..} =
  defMessage
    & #traceId .~ fromTraceId traceId
    & #spanId .~ fromSpanId spanId
    & #vec'attributes .~ toOtelAttributes attributes

type SpanLinks = Vector SpanLink

toOtelSpanLinks :: SpanLinks -> Vector Span'Link
toOtelSpanLinks = fmap toOtelSpanLink

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

-- | Error is human readable error text
data SpanStatus = SpanOk | SpanError Text

toOtelSpanStatus :: SpanStatus -> Status
toOtelSpanStatus SpanOk =
  defMessage
    & #code .~ Status'STATUS_CODE_OK
toOtelSpanStatus (SpanError errorMessage) =
  defMessage
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

data TraceEvent = TraceEvent
  { name :: !Text
  , attributes :: !Attributes
  }
  deriving stock (Show, Generic)
