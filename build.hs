{-# LANGUAGE OverloadedStrings #-}

-----------------------------------------------------------------------------
-- |
-- Simple little parser to smoosh together a set of M-lang expressions each
-- defined in a file of their own, into a single M Record statement.
--
-----------------------------------------------------------------------------

module Main where

import System.FilePath
import System.Directory (listDirectory)
import Data.Char (isSpace)
import Data.List (intercalate, isPrefixOf, sort)

--
-- Config

srcPath :: FilePath
srcPath = "./src"

srcExt :: FileExtension
srcExt = ".pq"

outFile :: FilePath
outFile = "./M" ++ srcExt

--

type FileExtension = String

data PQExpression = PQExpression { identifier :: String
                                 , expressionBody :: String
                                 } deriving (Show, Eq)

-- | List all files within a directory that have the specified extension.
lsFiles :: FileExtension -> FilePath -> IO [FilePath]
lsFiles x = fmap (filter hasExt) . files
    where
        files path = sort <$> listDirectory path
        hasExt = (==) x . takeExtension

-- | lsFiles with a relative path rather than file name.
lsFiles' :: FileExtension -> FilePath -> IO [FilePath]
lsFiles' ext dir = fmap (dir </>) <$> lsFiles ext dir


-- | Read a raw expression from a file.
readExpression :: FilePath -> IO PQExpression
readExpression file = do
    let name = takeBaseName file
    expression <- trim <$> readFile file
    pure $ PQExpression name expression

-- | Parse a folder of expression files into a list.
readExpressions :: FilePath -> IO [PQExpression]
readExpressions dir =
    lsFiles' srcExt dir >>=
    mapM readExpression


-- | Trim the leading and trailing whitespace from a String.
trim :: String -> String
trim = f . f
   where f = reverse . dropWhile isSpace

-- | Indent all lines by the specified number of spaces.
indent :: Int -> String -> String
indent n s = init . unlines $ (++) (replicate n ' ') <$> lines s

-- | Render a PQExpression to named statement.
render :: PQExpression -> String
render (PQExpression name body) = header ++ name ++ " = " ++ expression
    where
        (header, expression) = mapT unlines $ span isHeaderLine $ lines body
        mapT f (a, b)        = (f a, f b)
        isHeaderLine x
            | "/*" `isPrefixOf` x = True
            | " *" `isPrefixOf` x = True
            | otherwise           = False

-- | Join collection of expressions into an record statement.
toRecord :: [PQExpression] -> String
toRecord = group . merge . build
    where
        build   = fmap (indent 4 . render)
        merge   = intercalate ",\n\n"
        group x = "[\n" ++ x ++ "\n]"


main :: IO ()
main = do
    putStrLn $ "Building lib from components in " ++ srcPath ++ "\n"
    header <- readFile $ srcPath </> "_header.txt"
    expressions <- readExpressions srcPath
    writeFile outFile $ header ++ "\n" ++ toRecord expressions
    mapM_ (putStrLn . indent 2) (identifier <$> expressions)
    putStrLn "\nDone!"
