{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE RebindableSyntax          #-}
module PrettyPrint
  where

import qualified Data.ByteString.Char8 as ByteString (unpack)
import           Data.String
import           Parser                (parseFile)
import           Prelude               hiding (return, (>>), (>>=))
import qualified Prelude               ((>>), (>>=))
import           Syntax
import           Text.PrettyPrint

test :: IO ()
test = parseFile "./Dockerfile" Prelude.>>=
    (\(Right input) ->
       print input Prelude.>>
       putStrLn (prettyPrint input) Prelude.>>
       putStrLn "-----" Prelude.>>
       (putStrLn Prelude.=<< readFile "./Dockerfile"))

prettyPrint :: Dockerfile -> String
prettyPrint = unlines
    . reverse . snd . foldl removeDoubleBlank (False, [])
    . lines
    . unlines
    . map prettyPrintInstructionPos
  where
    removeDoubleBlank (True, m) "" = (True, m)
    removeDoubleBlank (False, m) "" = (True, "":m)
    removeDoubleBlank (_, m) s = (False, s:m)

prettyPrintInstructionPos :: InstructionPos -> String
prettyPrintInstructionPos (InstructionPos i _ _) = render (prettyPrintInstruction i)

prettyPrintBaseImage :: BaseImage -> Doc
prettyPrintBaseImage b =
    case b of
      DigestedImage name digest -> do
          text name
          char '@'
          text (ByteString.unpack digest)
      UntaggedImage name -> text name
      TaggedImage name tag -> do
          text name
          char ':'
          text tag
  where
    (>>) = (<>)
    return = (mempty <>)

prettyPrintPairs :: Pairs -> Doc
prettyPrintPairs ps = hsep $ map prettyPrintPair ps

prettyPrintPair :: (String, String) -> Doc
prettyPrintPair (k, v) = text k <> char '=' <> text (show v)

prettyPrintArguments :: Arguments -> Doc
prettyPrintArguments as = text (unwords (map helper as))
  where
    helper "&&" = "\\\n &&"
    helper a = a

prettyPrintInstruction :: Instruction -> Doc
prettyPrintInstruction i =
    case i of
      Maintainer m -> do
          text "MAINTAINER"
          text m
      Arg a -> do
          text "ARG"
          text a
      Entrypoint e -> do
          text "ENTRYPOINT"
          prettyPrintArguments e
      Stopsignal s -> do
          text "STOPSIGNAL"
          text s
      Workdir w -> do
          text "WORKDIR"
          text w
      Expose ps -> do
          text "EXPOSE"
          hsep (map (text . show) ps)
      Volume dir -> do
          text "VOLUME"
          text dir
      Run c -> do
          text "RUN"
          prettyPrintArguments c
      Copy s d -> hsep [ text "COPY"
                       , text s
                       , text d
                       ]
      Cmd c -> do
          text "CMD"
          prettyPrintArguments c
      Label l -> do
          text "LABEL"
          prettyPrintPairs l
      Env ps -> do
          text "ENV"
          prettyPrintPairs ps
      User u -> do
          text "USER"
          text u
      Comment s -> do
          char '#'
          text s
      OnBuild i' -> do
          text "ONBUILD"
          prettyPrintInstruction i'
      From b -> do
          text "FROM"
          prettyPrintBaseImage b
      Add s d -> do
          text "ADD"
          text s
          text d
      EOL -> mempty
  where
    (>>) = (<+>)
    return = (mempty <>)