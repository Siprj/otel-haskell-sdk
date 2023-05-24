{-# LANGUAGE MultiWayIf #-}

module Otel.Internal.Client (
  startOtelClient,
  OtelClientParameters (..),
  OtelClient (..),
  defautOtelClientParameters,
  chunkLogs,
) where

import Control.Concurrent
import Control.Concurrent.STM (atomically)
import Control.Exception (SomeException, catch)
import Control.Monad (forever, unless, void, when)
import Data.ByteString (ByteString)
import Data.Function ((&))
import Data.List (foldl')
import Data.Map.Strict (toList)
import Data.ProtoLens (Message (defMessage), encodeMessage)
import Data.Vector (Vector)
import GHC.Generics
import Lens.Micro ((.~))
import Network.HTTP.Client
import Network.HTTP.Types.Status (statusIsSuccessful)
import Numeric.Natural
import Otel.Internal.OtelQueue (OtelQueueSet, OtelSingleQueue, flushSingleQueueData, getQueueMap, newOtelQueueSetIO, queueLengthIO)
import Otel.Internal.Type (ResourceAttributes, ScopeData, toOtelAttributes, toOtelInstrumentationScope)
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest)
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService_Fields (resourceLogs)
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest)
import Proto.Opentelemetry.Proto.Common.V1.Common (KeyValue)
import Proto.Opentelemetry.Proto.Logs.V1.Logs (LogRecord, ResourceLogs, ScopeLogs)
import Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields qualified as LL
import Proto.Opentelemetry.Proto.Resource.V1.Resource (Resource)
import Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields qualified as LR
import Proto.Opentelemetry.Proto.Trace.V1.Trace (ResourceSpans, ScopeSpans, Span)
import Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields qualified as TL

data OtelClientParameters = OtelClientParameters
  { logEndpoint :: String
  -- ^ Full URL where the logging payload will be send including the
  -- domain name/IP.
  --
  -- Default value is: "http://localhost:4218/v1/logs"
  , traceEndpoint :: String
  -- ^ Full URL where the tracing payload will be send including the
  -- domain name/IP.
  --
  -- Default value is: "http://localhost:4218/v1/trace"
  , queueSize :: Natural
  -- ^ Queue size in elements. How many traces is going to be cached before
  -- they start to be drooped in case the logs/traces/metrics are generated to
  -- fast.
  -- Default value: 100000
  , logQueueChunkSize :: Int
  , traceQueueChunkSize :: Int
  }
  deriving stock (Show, Generic)

defautOtelClientParameters :: OtelClientParameters
defautOtelClientParameters =
  OtelClientParameters
    { logEndpoint = "http://localhost:4218/v1/logs"
    , traceEndpoint = "http://localhost:4218/v1/traces"
    , queueSize = 100000
    , logQueueChunkSize = 1000
    , traceQueueChunkSize = 100
    }

data OtelClient = OtelClient
  { httpManager :: Manager
  , logQueueSet :: OtelQueueSet ScopeData LogRecord
  , traceQueueSet :: OtelQueueSet ScopeData Span
  , logRequestBase :: Request
  , traceRequestBase :: Request
  , queueSize :: Natural
  , logQueueChunkSize :: Int
  , traceQueueChunkSize :: Int
  , resourceAttributes :: Vector KeyValue
  }

startOtelClient :: ResourceAttributes -> OtelClientParameters -> IO OtelClient
startOtelClient resourceAttributes' OtelClientParameters {..} = do
  httpManager <- newManager defaultManagerSettings
  parsedUrlLogRequest <- parseRequest logEndpoint
  let logRequestBase =
        parsedUrlLogRequest
          { method = "POST"
          , requestHeaders = [("Content-Type", "application/x-protobuf")]
          }
  parsedUrlTraceRequest <- parseRequest traceEndpoint
  let traceRequestBase =
        parsedUrlTraceRequest
          { method = "POST"
          , requestHeaders = [("Content-Type", "application/x-protobuf")]
          }
  let resourceAttributes = toOtelAttributes resourceAttributes'
  logQueueSet <- newOtelQueueSetIO queueSize
  traceQueueSet <- newOtelQueueSetIO queueSize
  let client = OtelClient {..}
  void . forkIO $ runLogClientProcess client
  void . forkIO $ runTraceClientProcess client
  pure client

when80Percent :: Natural -> Natural -> IO () -> IO ()
when80Percent value limit = when ((fromIntegral value) > (fromIntegral limit * (0.8 :: Double)))

runLogClientProcess :: OtelClient -> IO ()
runLogClientProcess OtelClient {..} = forever $ do
  logQueueLength <- queueLengthIO logQueueSet
  when80Percent logQueueLength queueSize $ putStrLn "WARNING: Logging queue is 80% full."
  scopeQueues <- fmap toList . atomically $ getQueueMap logQueueSet
  data' <- mapM fetchQueue scopeQueues
  let logChunks = chunkLogs mkScopeLogs data' logQueueChunkSize
  mapM_ (sendPayload httpManager logRequestBase . requestPayload) logChunks
  where
    requestPayload :: [ScopeLogs] -> ByteString
    requestPayload = encodeMessage . requestData . otelResourceLogs resourceAttributes
    requestData :: ResourceLogs -> ExportLogsServiceRequest
    requestData xs = defMessage @ExportLogsServiceRequest & resourceLogs .~ [xs]

runTraceClientProcess :: OtelClient -> IO ()
runTraceClientProcess OtelClient {..} = forever $ do
  traceQueueLength <- queueLengthIO traceQueueSet
  when80Percent traceQueueLength queueSize $ putStrLn "WARNING: Tracing queue is 80% full."
  scopeQueues <- fmap toList . atomically $ getQueueMap traceQueueSet
  data' <- mapM fetchQueue scopeQueues
  let scopeChunks = chunkLogs mkScopeSpans data' traceQueueChunkSize
  mapM_ (sendPayload httpManager traceRequestBase . requestPayload) scopeChunks
  where
    requestPayload :: [ScopeSpans] -> ByteString
    requestPayload = encodeMessage . requestData . otelResourceSpans resourceAttributes
    requestData :: ResourceSpans -> ExportTraceServiceRequest
    requestData xs = defMessage @ExportTraceServiceRequest & TL.resourceSpans .~ [xs]

sendPayload :: Manager -> Request -> ByteString -> IO ()
sendPayload httpManager logRequestBase payload = do
  catch sendRequest $ \(e :: SomeException) ->
    putStrLn $ "ERROR: Sending otel data to \"" <> show (getUri request) <> "\" filed with: " <> show e
  where
    sendRequest :: IO ()
    sendRequest = do
      response <- httpLbs request httpManager
      unless (statusIsSuccessful $ responseStatus response)
        . putStrLn
        $ "ERROR: Sending otel data to \"" <> show (getUri request) <> "\" filed with: " <> show response
    request :: Request
    request = logRequestBase {requestBody = RequestBodyBS payload}

fetchQueue :: (ScopeData, OtelSingleQueue a) -> IO (ScopeData, [a])
fetchQueue (scope, queue) = do
  queueData <- atomically $ flushSingleQueueData queue
  pure (scope, queueData)

chunkLogs :: forall a b c. (a -> [b] -> c) -> [(a, [b])] -> Int -> [[c]]
chunkLogs mk queueLogs chunkSize = do
  snd $ foldl' foldChunkFunction (chunkSize, []) queueLogs
  where
    -- \| Expect the logs to be nonepty list!!!
    foldChunkFunction :: (Int, [[c]]) -> (a, [b]) -> (Int, [[c]])
    foldChunkFunction (remains, chunks) (scope, logs) =
      let (xs, xss) = splitAt remains logs
          xslen = length xs
          mkChunk :: [[c]]
          mkChunk
            | xslen == 0 = chunks
            | remains == chunkSize = [mk scope xs] : chunks
            | otherwise = (mk scope xs : head chunks) : tail chunks
       in if xslen < remains
            then (remains - xslen, mkChunk)
            else foldChunkFunction' scope chunkSize xss mkChunk

    foldChunkFunction' :: a -> Int -> [b] -> [[c]] -> (Int, [[c]])
    foldChunkFunction' scope remains logs chunks =
      let (xs, xss) = splitAt remains logs
          xslen = length xs
       in if
              | xslen == 0 -> (remains, chunks)
              | xslen < remains -> (remains - xslen, [mk scope xs] : chunks)
              | otherwise -> foldChunkFunction' scope chunkSize xss ([mk scope xs] : chunks)

otelResourceLogs :: Vector KeyValue -> [ScopeLogs] -> ResourceLogs
otelResourceLogs resourceAttributes scopeLogs =
  defMessage
    & LL.scopeLogs .~ scopeLogs
    & LL.resource .~ otelResource resourceAttributes

otelResource :: Vector KeyValue -> Resource
otelResource resourceAttributes =
  defMessage
    & LR.vec'attributes .~ resourceAttributes

mkScopeLogs :: ScopeData -> [LogRecord] -> ScopeLogs
mkScopeLogs scope logRecords =
  defMessage
    & LL.scope .~ toOtelInstrumentationScope scope
    & LL.logRecords .~ logRecords

mkScopeSpans :: ScopeData -> [Span] -> ScopeSpans
mkScopeSpans scope spans =
  defMessage
    & TL.scope .~ toOtelInstrumentationScope scope
    & TL.spans .~ spans

otelResourceSpans :: Vector KeyValue -> [ScopeSpans] -> ResourceSpans
otelResourceSpans resourceAttributes scopeSpans =
  defMessage
    & TL.scopeSpans .~ scopeSpans
    & TL.resource .~ otelResource resourceAttributes
