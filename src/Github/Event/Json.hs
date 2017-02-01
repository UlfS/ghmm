{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Github.Event.Json
    ( decodeEvent
    ) where

import           Data.Aeson
import           Data.Aeson.Types
import           Data.Map
import qualified Data.Map           as M
import           Data.Text          (Text)

import           Github.Event.Types

-- ----------------------------------------------

headerToConstructor :: Text -> Maybe Text
headerToConstructor = flip M.lookup mapping
  where
  mapping = fromList
    [ ("push",                        "PushEvent")
    , ("pull_request",                "PullRequestEvent")
    , ("status",                      "StatusEvent")
    , ("issue_comment",               "IssueCommentEvent")
    , ("pull_request_review",         "PullRequestReviewEvent")
    , ("pull_request_review_comment", "PullRequestReviewCommentEvent")
    ]


decodeEvent :: Text -> Value -> Either String EventPayload
decodeEvent eventType v =
  case headerToConstructor eventType of
    Just constructor -> parseJSON' constructor v
    Nothing          -> fail "unknown event type"

injectConstructor :: Text -> Value -> Value
injectConstructor h o = object [h .= o]

parseJSON' :: FromJSON a => Text -> Value -> Either String a
parseJSON' c = parseEither $ parseJSON . injectConstructor c
