{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (
  main,
) where

import Control.Concurrent (threadDelay)
import Control.Monad
import Control.Monad.Catch (Exception, MonadThrow (throwM), SomeException, try)
import Data.Text qualified as T
import Effectful
import Otel.Client
import Otel.Effect (logInfo_, logWarn_, runOtel, traceInternal_, traceServer_, withInstrumentationScope)
import Otel.Type
import Prelude hiding (log)

myAppScope :: Scope "my-app" "0.0.0.1"
myAppScope = Scope

data TestException = TestException
  deriving (Show)

instance Exception TestException

main :: IO ()
main = do
  otelClient <- startOtelClient resourceAttributes defautOtelClientParameters
  app otelClient
  where
    app :: OtelClient -> IO ()
    app otelClient = forever . runEff $ runOtel otelClient (Just $ TraceData "Root span" Server mempty mempty) $ do
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

        liftIO $ threadDelay 10

resourceAttributes :: ResourceAttributes
resourceAttributes =
  [ KeyValue "machine" $ KvlistV [KeyValue "name" $ StringV "machine-name"]
  , KeyValue "machine.id" $ StringV "123"
  , KeyValue "container_name" $ StringV "example-container"
  ]

