{-# LANGUAGE ViewPatterns #-}
import Data.List

main = do
  contents <- getContents
  pilot . lines $ contents

pilot l = printp $ foldl (\(h, d, a, d2) command -> execute command (h, d, a, d2)) (0,0,0,0) l

printp (h, d, a, d2) = do
  putStrLn $ "Part1: " ++ show (h * d)
  putStrLn $ "Part2: " ++ show (h * d2)

execute (stripPrefix "forward " -> Just string) (h, d, a, d2) = do
  let v = read string :: Integer
  (h + v, d, a, d2 + a * v)
execute (stripPrefix "up " -> Just string) (h, d, a, d2)= do
  let v = read string :: Integer
  (h, d - v, a - v, d2)
execute (stripPrefix "down " -> Just string) (h, d, a, d2) = do
  let v = read string :: Integer
  (h, d + v, a + v, d2)
execute string (h, d, a, d2) = (h, d, a, d2)