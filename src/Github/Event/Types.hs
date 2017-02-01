{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Github.Event.Types
    ( Event(..)
    , EventPayload(..)
    , Commit(..)
    , PushCommit(..)
    , Repository(..)
    , PullRequest(..)
    , Issue(..)
    , Comment(..)
    , User(..)
    , Review(..)

    , isPushEvent
    , isPullRequestEvent
    , isStatusEvent
    , isIssueCommentEvent
    , isPullRequestReviewEvent
    , isPullRequestReviewCommentEvent
    ) where

import           GHC.Generics

import           Data.Aeson
import           Data.Aeson.Types
import           Data.Char
import           Data.Text        (Text)

-- ----------------------------------------------

data Event = Event
  { evtPayload :: EventPayload
  , evtType    :: Text
  , evtId      :: Text
  }


{-# ANN type EventPayload ("HLint: ignore Use camelCase" :: Text) #-}
data EventPayload
  = PushEvent
    { epuRef         :: Text
    , epuCommits     :: [PushCommit]
    , epuHead_commit :: PushCommit
    , epuCompare     :: Text
    , epuRepository  :: Repository
    }
  | PullRequestEvent
    { eprAction       :: Text
    , eprNumber       :: Int
    , eprPull_request :: PullRequest
    , eprRepository   :: Repository
    }
  | StatusEvent
    { estSha         :: Text
    , estState       :: Text
    , estDescription :: Maybe Text
    , estCommit      :: Commit
    , estTarget_url  :: Maybe Text
    , estRepository  :: Repository
    }
  | IssueCommentEvent
    { ecoAction     :: Text
    , ecoIssue      :: Issue
    , ecoComment    :: Comment
    , ecoRepository :: Repository
    }
  | PullRequestReviewEvent
    { ervAction       :: Text
    , ervReview       :: Review
    , ervPull_request :: PullRequest
    , ervRepository   :: Repository
    }
  | PullRequestReviewCommentEvent
    { ercAction       :: Text
    , ercComment      :: Comment
    , ercPull_request :: PullRequest
    , ercRepository   :: Repository
    } deriving (Eq, Show, Generic)

instance FromJSON EventPayload where
  parseJSON = genericParseJSON jsonParseOpts


data PushCommit = PushCommit
  { pcmId      :: Text
  , pcmMessage :: Text
  } deriving (Eq, Show, Generic)

instance FromJSON PushCommit where
  parseJSON = genericParseJSON jsonParseOpts


{-# ANN type Commit ("HLint: ignore Use camelCase" :: Text) #-}
data Commit = Commit
  { cmtSha      :: Text
  , cmtHtml_url :: Text
  } deriving (Eq, Show, Generic)

instance FromJSON Commit where
  parseJSON = genericParseJSON jsonParseOpts


{-# ANN type Repository ("HLint: ignore Use camelCase" :: Text) #-}
data Repository = Repository
  { repName     :: Text
  , repHtml_url :: Text
  } deriving (Eq, Show, Generic)

instance FromJSON Repository where
  parseJSON = genericParseJSON jsonParseOpts


data Pusher = Pusher
  { pshEmail :: Text
  } deriving (Eq, Show, Generic)

instance ToJSON Pusher

{-# ANN type PullRequest ("HLint: ignore Use camelCase" :: Text) #-}
data PullRequest = PullRequest
  { purNumber   :: Int
  , purHtml_url :: Text
  , purState    :: Text
  , purTitle    :: Text
  } deriving (Eq, Show, Generic)

instance FromJSON PullRequest where
  parseJSON = genericParseJSON jsonParseOpts

{-# ANN type Comment ("HLint: ignore Use camelCase" :: Text) #-}
data Comment = Comment
  { comHtml_url :: Text
  , comBody     :: Text
  , comUser     :: User
  } deriving (Eq, Show, Generic)

instance FromJSON Comment where
  parseJSON = genericParseJSON jsonParseOpts

{-# ANN type User ("HLint: ignore Use camelCase" :: Text) #-}
data User = User
  { usrLogin    :: Text
  , usrHtml_url :: Text
  } deriving (Eq, Show, Generic)

instance FromJSON User where
  parseJSON = genericParseJSON jsonParseOpts

{-# ANN type Issue ("HLint: ignore Use camelCase" :: Text) #-}
data Issue = Issue
  { issState    :: Text
  , issHtml_url :: Text
  , issUser     :: User
  -- XXX: add labels, assignee etc.
  } deriving (Eq, Show, Generic)

instance FromJSON Issue where
  parseJSON = genericParseJSON jsonParseOpts

{-# ANN type Review ("HLint: ignore Use camelCase" :: Text) #-}
data Review = Review
  { revHtml_url     :: Text
  , revBody         :: Text
  , revState        :: Text
  , revUser         :: User
  } deriving (Eq, Show, Generic)

instance FromJSON Review where
  parseJSON = genericParseJSON jsonParseOpts


-- TODO: smarter way to detect prefix (for camel and snake case)
jsonParseOpts :: Options
jsonParseOpts = defaultOptions
  { fieldLabelModifier = labelModifier
  ,sumEncoding = ObjectWithSingleField
  }
  where
  labelModifier name = let (x:xs) = drop 3 name in switchCase x : xs -- XXX: don't forget the prefix or BOOM
  switchCase a = if isUpper a then toLower a else toUpper a

-- ----------------------------------------------

isPushEvent :: EventPayload -> Bool
isPushEvent PushEvent{} = True
isPushEvent _           = False

isPullRequestEvent :: EventPayload -> Bool
isPullRequestEvent PullRequestEvent{} = True
isPullRequestEvent _                  = False

isStatusEvent :: EventPayload -> Bool
isStatusEvent StatusEvent{} = True
isStatusEvent _             = False

isIssueCommentEvent :: EventPayload -> Bool
isIssueCommentEvent IssueCommentEvent{} = True
isIssueCommentEvent _                   = False

isPullRequestReviewEvent :: EventPayload -> Bool
isPullRequestReviewEvent PullRequestReviewEvent{} = True
isPullRequestReviewEvent _                        = False

isPullRequestReviewCommentEvent :: EventPayload -> Bool
isPullRequestReviewCommentEvent PullRequestReviewCommentEvent{} = True
isPullRequestReviewCommentEvent _                               = False
