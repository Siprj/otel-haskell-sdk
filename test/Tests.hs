module Main (main) where

import Otel.Internal.Client (chunkLogs)
import Test.Tasty
import Test.Tasty.HUnit

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "all" [clientTests]

clientTests :: TestTree
clientTests = testGroup "client" [chunkLogs1, chunkLogs2, chunkLogs3, chunkLogs4, chunkLogs5]

simpleFunction :: Int -> [Int] -> (Int, [Int])
simpleFunction a bs = (a, bs)

dataToChunk :: [(Int, [Int])]
dataToChunk = [(1, [1, 2, 3]), (2, [1, 2]), (3, [1]), (4, [])]

chunkLogsWithData :: Int -> [[(Int, [Int])]]
chunkLogsWithData = chunkLogs simpleFunction dataToChunk

chunkLogs1 :: TestTree
chunkLogs1 = testCase "simple" $ expectedResult @=? chunkLogsWithData 1
  where
    expectedResult = [[(3, [1])], [(2, [2])], [(2, [1])], [(1, [3])], [(1, [2])], [(1, [1])]]

chunkLogs2 :: TestTree
chunkLogs2 = testCase "simple" $ expectedResult @=? chunkLogsWithData 2
  where
    expectedResult = [[(3, [1]), (2, [2])], [(2, [1]), (1, [3])], [(1, [1, 2])]]

chunkLogs3 :: TestTree
chunkLogs3 = testCase "simple" $ expectedResult @=? chunkLogsWithData 5
  where
    expectedResult = [[(3, [1])], [(2, [1, 2]), (1, [1, 2, 3])]]

chunkLogs4 :: TestTree
chunkLogs4 = testCase "simple" $ expectedResult @=? chunkLogsWithData 6
  where
    expectedResult = [[(3, [1]), (2, [1, 2]), (1, [1, 2, 3])]]

chunkLogs5 :: TestTree
chunkLogs5 = testCase "simple" $ expectedResult @=? chunkLogsWithData 7
  where
    expectedResult = [[(3, [1]), (2, [1, 2]), (1, [1, 2, 3])]]
