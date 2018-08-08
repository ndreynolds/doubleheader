module Model.PlayerAction exposing (..)

import Json.Encode exposing (Value, string)
import Model.Card exposing (Card, encodeCard)


type PlayerAction
    = Bid BidValue -- Announcement | Play Card
    | Play Card


type BidValue
    = Healthy
    | Marriage --| Poverty | Solo SoloType


encodePlayerAction : PlayerAction -> ( String, Value )
encodePlayerAction action =
    ( encodePlayerActionType action, encodePlayerActionValue action )


encodePlayerActionType : PlayerAction -> String
encodePlayerActionType action =
    case action of
        Bid _ ->
            "bid"

        Play _ ->
            "play"


encodePlayerActionValue : PlayerAction -> Value
encodePlayerActionValue action =
    case action of
        Bid Healthy ->
            string "healthy"

        Bid Marriage ->
            string "marriage"

        Play card ->
            encodeCard card
