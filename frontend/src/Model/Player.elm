module Model.Player exposing (Player, PlayerName, playerDecoder)

import Json.Decode as JD
import Json.Decode.Pipeline exposing (decode, required)
import Model.Card exposing (Card, cardDecoder)


type alias Player =
    { bid : Maybe String
    , name : PlayerName
    , hand : List Card
    , score : Int
    }


type alias PlayerName =
    String


playerDecoder : JD.Decoder Player
playerDecoder =
    decode Player
        |> required "bid" (JD.maybe JD.string)
        |> required "name" JD.string
        |> required "hand" (JD.list cardDecoder)
        |> required "score" JD.int
