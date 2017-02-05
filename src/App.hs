{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- | The app, it's runtime context and configuration.
module App where

import           Control.Monad.Except (ExceptT, MonadError)
import           Control.Monad.Reader (MonadIO, MonadReader, ReaderT, asks)

import           System.Log           (Priority)

import           Data.ByteString      (ByteString)
import           Data.Text            (Text)

import qualified Network.HTTP.Client  as HttpClient

import           Servant

-- ----------------------------------------------

-- | The app's monad stack.
newtype App a = App
  { runApp :: ReaderT AppContext (ExceptT ServantErr IO) a
  } deriving ( Functor, Applicative, Monad, MonadReader AppContext,
               MonadError ServantErr, MonadIO)

-- | The context the app has access to during runtime.
data AppContext = AppContext
  { ctxConfiguration     :: Configuration       -- App configuration
  , ctxHttpClientManager :: HttpClient.Manager  -- HTTP Client manager to use for http calls
  }

-- | The app configuration.
data Configuration = Configuration
 { cfgPort             :: Int               -- ^ Port to listen on
 , cfgPriority         :: Priority          -- ^ Debug level
 , cfgGithubSecret     :: Maybe ByteString  -- ^ Shared secret for the incoming GitHub webhook calls
 , cfgMattermostUrl    :: Text              -- ^ Mattermost base URL
 , cfgMattermostPort   :: Int               -- ^ Mattermost port, usuall 443
 , cfgMattermostApiKey :: Text              -- ^ Mattermost API key - the last part of the incoming webhook URL
 }

 -- ----------------------------------------------

-- | Get the configuration in app context.
cfg :: MonadReader AppContext m => (Configuration -> a) -> m a
cfg f = asks (f . ctxConfiguration)
