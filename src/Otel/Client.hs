module Otel.Client
  ( createOtelClient
  , OtelClientParameters(logEnpoint, traceEndpoint, queueSize, queueTimeout)
  , defautOtelClientParameters
  )
where

import GHC.Generics
import Numeric.Natural
import Network.HTTP.Client
import Control.Concurrent.STM.TBQueue
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService

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
  , queueTimeout :: Natural
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
  , queueLogs :: TBQueue ExportLogsServiceRequest
  , queueTraces :: TBQueue ExportTraceServiceRequest
  , logRequestBase :: Request
  , traceRequestBase :: Request
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
  pure $ OtelClient {..}

