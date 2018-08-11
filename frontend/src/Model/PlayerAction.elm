module Model.PlayerAction exposing (..)

import Json.Encode as JE
import Model.Card exposing (Card, encodeCard)


type PlayerAction
    = Bid BidValue -- Announcement | Play Card
    | Play Card


type BidValue
    = Healthy
    | Marriage --| Poverty | Solo SoloType


encodePlayerAction : PlayerAction -> ( String, JE.Value )
encodePlayerAction action =
    ( encodePlayerActionType action, encodePlayerActionValue action )


encodePlayerActionType : PlayerAction -> String
encodePlayerActionType action =
    case action of
        Bid _ ->
            "bid"

        Play _ ->
            "play"


encodePlayerActionValue : PlayerAction -> JE.Value
encodePlayerActionValue action =
    case action of
        Bid Healthy ->
            JE.string "healthy"

        Bid Marriage ->
            JE.string "marriage"

        Play card ->
            encodeCard card
