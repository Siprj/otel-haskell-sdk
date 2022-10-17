{-# LANGUAGE TypeFamilies #-}

module Lib (
  greet,
  Arguments (..),
) where

import Control.Concurrent (threadDelay)
import Control.Monad
import Data.ProtoLens.Labels ()
import Data.Text qualified as T
import Effectful
import GHC.Generics
import GHC.Natural (Natural)
import Options.Applicative
import Otel.Client
import Otel.Effect (logInfo_, logWarn_, runOtel, traceServer_, withInstrumentationScope, traceInternal_)
import Otel.Type
import Prelude hiding (log)
import Control.Monad.Catch (try, MonadThrow (throwM), Exception, SomeException)

data Arguments = Arguments
  { insertDelay :: Int
  , queueSize :: Natural
  , chunkSize :: Int
  }
  deriving stock (Generic, Show)

argumentParser :: Parser Arguments
argumentParser =
  Arguments
    <$> option
      auto
      ( long "insert-delay"
          <> short 'i'
          <> help "Delay before the log is inserted into the queue."
      )
    <*> option
      auto
      ( long "queue-size"
          <> short 's'
          <> help "Size of the queue before it starts blocking."
      )
    <*> option
      auto
      ( long "chunk-size"
          <> short 'c'
          <> help "Size of the chunks for sending logs."
      )

argumentParserInfo :: ParserInfo Arguments
argumentParserInfo = info (helper <*> argumentParser) fullDesc

myAppScope :: Scope "my-app" "0.0.0.1"
myAppScope = Scope

data TestException = TestException
  deriving stock (Show)
instance Exception TestException

greet :: IO ()
greet = do
  Arguments {..} <- execParser argumentParserInfo
  let otelParameters =
        defautOtelClientParameters
          { queueSize
          , logQueueChunkSize = chunkSize
          }
  otelClient <- startOtelClient resourceAttributes otelParameters
  app otelClient insertDelay
  where
    app :: OtelClient -> Int -> IO ()
    app otelClient insertDelay = forever . runEff $ runOtel otelClient (Just $ TraceData "Root span" Server mempty mempty) $ do
      traceServer_ "Outer span" $ do
        mapM_ (\v -> logInfo_ $ "Super cool message in default scope " <> T.pack (show @Int v)) [1 .. 200]
        withInstrumentationScope myAppScope $ do
          traceServer_ "Inside span" $ do
            mapM_ (\v -> logWarn_ $ "Super cool message in my app scope " <> T.pack (show @Int v)) [1 .. 200]
          traceInternal_ "Some internal span" $ do
            void . try @_ @SomeException $ do
              traceInternal_ "Second internal span" $ do
                logInfo_ "Nice message before throw"
                void $ throwM TestException
                logInfo_ "Nice message after throw"

        liftIO $ threadDelay insertDelay

resourceAttributes :: ResourceAttributes
resourceAttributes =
  [ KeyValue "machine" $ KvlistV [KeyValue "name" $ StringV "machine-name"]
  , KeyValue "machine.id" $ StringV "123"
  , KeyValue "container_name" $ StringV "blabla container"
  ]
