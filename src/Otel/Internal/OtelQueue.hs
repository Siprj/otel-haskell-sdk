-- |
-- `OtelQueue` is scope separated set of bounded concurrent queues. The
-- assumption is that there is finite (small) amount of keys across the
-- application run time.
--
-- The amount of keys is mitigated by using the `Otel.Type.TypeScope` instead
-- of directly
-- using Scope in the public API.
module Otel.Internal.OtelQueue (
  OtelSingleQueue,
  OtelQueueSet,
  newOtelQueueSet,
  newOtelQueueSetIO,
  getSingleQueue,
  getQueueMap,
  insertIntoSingeQueue,
  flushSingleQueueData,
  queueLength,
  queueLengthIO,
) where

import Control.Concurrent.STM
import Control.Monad (when)
import Data.Map.Strict qualified as MS
import GHC.Generics
import Numeric.Natural (Natural)

-- | Map of individual queues with some global counters to allow queue limiting.
data OtelQueueSet key value = OtelQueueSet
  { globalCounter :: TVar Natural
  , globalQueues :: TVar (MS.Map key (OtelSingleQueue value))
  , globalCapacity :: Natural
  }
  deriving stock (Generic)

-- | Single queue containing data. This queue is similar to
-- `Control.Concurrent.STM.TBQueue` in some ways.
data OtelSingleQueue value = OtelSingleQueue
  { globalCounter :: TVar Natural
  , globalCapacity :: Natural
  , localQueue :: TVar [value]
  , localCounter :: TVar Int
  }
  deriving stock (Generic)

-- | Create new queue with its size as parameter.
newOtelQueueSet :: (Ord key) => Natural -> STM (OtelQueueSet key value)
newOtelQueueSet globalCapacity = do
  globalCounter <- newTVar 0
  globalQueues <- newTVar mempty
  pure $ OtelQueueSet {..}

-- | IO variant of `newOtelQueueSet`
newOtelQueueSetIO :: (Ord key) => Natural -> IO (OtelQueueSet key value)
newOtelQueueSetIO = atomically . newOtelQueueSet

-- | Either creates new single queue or return existing one corresponding to
-- the key.
getSingleQueue ::
  (Ord key) => key -> OtelQueueSet key value -> STM (OtelSingleQueue value)
getSingleQueue key OtelQueueSet {..} = do
  queueMap <- readTVar globalQueues
  case MS.lookup key queueMap of
    Just signeQueue ->
      pure signeQueue
    Nothing -> do
      localQueue <- newTVar []
      localCounter <- newTVar 0
      let singleQueue =
            OtelSingleQueue
              { globalCounter
              , globalCapacity
              , localCounter
              , localQueue
              }

      modifyTVar globalQueues (MS.insert key singleQueue)
      pure singleQueue

-- | Returns map of `OtelSingleQueue`s, so the data can be individually
-- collected. This is useful to reduce the number of STM clashes, because this
-- operation is simpler then walking over all keys and retrieving data for
-- corresponding queues.
--
-- NOTE: Blocks until there is data available.
getQueueMap ::
  OtelQueueSet key value -> STM (MS.Map key (OtelSingleQueue value))
getQueueMap OtelQueueSet {..} = do
  count <- readTVar globalCounter
  when (count == 0) retry
  readTVar globalQueues

-- | Inserts into the single queue one element.
--
-- NOTE: Blocks if the queue is full.
insertIntoSingeQueue :: OtelSingleQueue value -> value -> STM ()
insertIntoSingeQueue OtelSingleQueue {..} value = do
  numberOfElements <- readTVar globalCounter
  if numberOfElements < globalCapacity
    then do
      -- Strict modification of the queue size to avoid space leak
      writeTVar globalCounter $! numberOfElements + 1
      modifyTVar' localCounter (+ 1)
    else retry
  modifyTVar' localQueue (value :)

-- | Get data from single queue for processing. This is used in tandem with
-- `getQueueMap`.
flushSingleQueueData :: OtelSingleQueue value -> STM [value]
flushSingleQueueData OtelSingleQueue {..} = do
  numberOfElements <- readTVar globalCounter
  modifyTVar' globalCounter (numberOfElements -)
  writeTVar localCounter 0
  queueData <- readTVar localQueue
  writeTVar localQueue []
  pure queueData

queueLength :: OtelQueueSet key value -> STM Natural
queueLength OtelQueueSet {..} = readTVar globalCounter

queueLengthIO :: OtelQueueSet key value -> IO Natural
queueLengthIO OtelQueueSet {..} = readTVarIO globalCounter
