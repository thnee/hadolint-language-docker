module Language.Dockerfile.EDSL.PluginsSpec
  where

-- import           Language.Dockerfile.EDSL
-- import           Language.Dockerfile.EDSL.Plugins
import           Test.Hspec

spec =
    describe "listPlugins" $
        it "lists docker images matching language-dockerfile-*" pending
            -- str <- toDockerFileStrIO $ do
            --     ds <- liftIO (glob "./test/*.hs")
            --     from "ubuntu"
            --     mapM_ add ds
            -- str `shouldBe` unlines [ "FROM ubuntu"
            --                        , "ADD Spec.hs"
            --                        , "ADD SanitySpec.hs"
            --                        , "ADD Test.hs"
            --                        ]
