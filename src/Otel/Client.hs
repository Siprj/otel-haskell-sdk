module Otel.Client
  ( createOtelClient
  , OtelClientParameters(..)
  , OtelClient(..)
  , defautOtelClientParameters
  )
where

import GHC.Generics
import Data.Vector (fromList)
import Numeric.Natural
import Network.HTTP.Client
import Control.Concurrent.STM.TBQueue
import Lens.Micro
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest)
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService_Fields (vec'resourceLogs)
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService
import Control.Concurrent
import Control.Monad (void, forever)
import Control.Concurrent.STM (atomically)
import Data.ProtoLens (defMessage, encodeMessage)
import Data.Foldable (forM_)

data OtelClientParameters = OtelClientParameters
  { logEnpoint :: String
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
  , queueTimeout :: Int
  -- ^ How long to wait for batch processing. Value is in microseconds.
  -- Default value is: 1000000 us (1s).
  }
  deriving stock (Show, Generic)

defautOtelClientParameters :: OtelClientParameters
defautOtelClientParameters = OtelClientParameters
  { logEnpoint = "http://localhost:4218/v1/logs"
  , traceEndpoint = "http://localhost:4218/v1/trace"
  , queueSize = 100000
  , queueTimeout = 1000000
  }

data OtelClient = OtelClient
  { httpManager :: Manager
  -- TODO: I don't think using Request is good idea :).
  , queueLogs :: TBQueue ResourceLogs
  , queueTraces :: TBQueue ExportTraceServiceRequest
  , logRequestBase :: Request
  , traceRequestBase :: Request
  , queueTimeout :: Int
  }


-- TODO: Think about wrapping error handling
createOtelClient :: OtelClientParameters -> IO OtelClient
createOtelClient OtelClientParameters{..} = do
  -- TODO: TLS needs to be added into the manager
  httpManager <- newManager defaultManagerSettings
  -- TODO: Pass the URL as parameter
  parsedUrlLogRequest <- parseRequest logEnpoint
  let logRequestBase = parsedUrlLogRequest
        { method = "POST"
        , requestHeaders = [("Content-Type", "application/x-protobuf")]
        }
  parsedUrlTraceRequest <- parseRequest traceEndpoint
  let traceRequestBase = parsedUrlTraceRequest
        { method = "POST"
        , requestHeaders = [("Content-Type", "application/x-protobuf")]
        }
  queueLogs <- newTBQueueIO queueSize
  queueTraces <- newTBQueueIO queueSize
  let client = OtelClient {..}
  clientThreadId <- forkIO $ runClientProcess client
  -- FIXME: This threadId should be used somewhere to be able to terminate the
  -- logging safely.
  void $ pure clientThreadId
  pure client

runClientProcess :: OtelClient -> IO ()
runClientProcess OtelClient{..} = forever $ do
  putStrLn "processing queue"

  logMessages <- atomically (flushTBQueue queueLogs)
  putStrLn  "*****************************************"
  putStrLn $ "number of logs: " <> show (length logMessages)
  putStrLn "*****************************************"
--  let logData = encodeMessage $ logRequest logMessages
--  httpLbs logRequestBase{requestBody = RequestBodyBS logData } httpManager >>= print
  mvars <- batchProcessing [] 5000 logMessages
  waitForThreads mvars
  traceMessages <- fmap encodeMessage <$> atomically (flushTBQueue queueTraces)
  putStrLn $ "number of traces: " <> show (length traceMessages)
  forM_ traceMessages $ \message -> httpLbs traceRequestBase{requestBody = RequestBodyBS message} httpManager >>= print
  putStrLn "waiting for the queue"
  threadDelay queueTimeout
  where
    logRequest :: [ResourceLogs] -> ExportLogsServiceRequest
    logRequest logMessages = defMessage & vec'resourceLogs .~ fromList logMessages

    batchProcessing :: [MVar ()] -> Int -> [ResourceLogs] -> IO [MVar ()]
    batchProcessing mvars _ [] = pure mvars
    batchProcessing mvars size logs = do
      let (xs, xss) = splitAt size logs

      mvar <- newEmptyMVar
      runInFork mvar $ httpLbs logRequestBase{requestBody = RequestBodyBS . encodeMessage $ logRequest xs } httpManager >>= print
      batchProcessing (mvar : mvars) size xss

    runInFork :: MVar () -> IO () -> IO ()
    runInFork mvar io = void $ forkFinally io (\_ -> putMVar mvar ())

    waitForThreads :: [MVar ()] -> IO ()
    waitForThreads = mapM_ readMVar
