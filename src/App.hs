{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module App where

import           Control.Monad.Except (ExceptT, MonadError)
import           Control.Monad.Reader (MonadIO, MonadReader, ReaderT, asks)

import           Data.ByteString      (ByteString)
import           Data.Text            (Text)

import qualified Network.HTTP.Client  as HttpClient

import           Servant

-- ----------------------------------------------

newtype App a = App
  { runApp :: ReaderT AppContext (ExceptT ServantErr IO) a
  } deriving ( Functor, Applicative, Monad, MonadReader AppContext,
               MonadError ServantErr, MonadIO)

data AppContext = AppContext
  { ctxConfiguration     :: Configuration
  , ctxHttpClientManager :: HttpClient.Manager
  }

data Configuration = Configuration
 { cfgPort             :: Int
 , cfgGithubSecret     :: Maybe ByteString
 , cfgMattermostUrl    :: Text
 , cfgMattermostPort   :: Int
 , cfgMattermostApiKey :: Text
 }

 -- ----------------------------------------------

config :: MonadReader AppContext m => (Configuration -> a) -> m a
config f = asks (f . ctxConfiguration)
