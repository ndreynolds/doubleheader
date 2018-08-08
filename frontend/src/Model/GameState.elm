module Model.GameState
    exposing
        ( GameId
        , GameState
        , availableActions
        , gameIdDecoder
        , gameStateDecoder
        )

import Json.Decode exposing (Decoder, index, int, list, map4, maybe)
import Json.Decode.Pipeline exposing (decode, required)
import Model.Card exposing (Card, cardDecoder)
import Model.Player exposing (Player, PlayerName, playerDecoder)
import Model.PlayerAction exposing (BidValue(..), PlayerAction(..))
import Model.Status exposing (Status(..), statusDecoder)
import Model.Trick
    exposing
        ( CompleteTrick
        , IncompleteTrick
        , ScoredTrick
        , incompleteTrickDecoder
        , scoredTrickDecoder
        )


type alias GameState =
    { id : Int
    , deck : List Card
    , players : ( Maybe Player, Maybe Player, Maybe Player, Maybe Player )
    , currentTrick : IncompleteTrick
    , scoredTricks : List ScoredTrick
    , status : Status
    }


type alias GameId =
    Int


availableActions : Player -> Status -> List PlayerAction
availableActions player status =
    case status of
        AwaitingBids ->
            case player.bid of
                Just _ ->
                    []

                Nothing ->
                    [ Bid Healthy
                    , Bid Marriage
                    ]

        AwaitingAction playerName ->
            if playerName == player.name then
                List.map Play player.hand
            else
                []

        _ ->
            []


playerTupleDecoder : Decoder ( Maybe Player, Maybe Player, Maybe Player, Maybe Player )
playerTupleDecoder =
    map4 tuple4
        (maybe (index 0 playerDecoder))
        (maybe (index 1 playerDecoder))
        (maybe (index 2 playerDecoder))
        (maybe (index 3 playerDecoder))


gameIdDecoder : Decoder Int
gameIdDecoder =
    int


gameStateDecoder : Decoder GameState
gameStateDecoder =
    decode GameState
        |> required "id" gameIdDecoder
        |> required "deck" (list cardDecoder)
        |> required "players" playerTupleDecoder
        |> required "current_trick" incompleteTrickDecoder
        |> required "scored_tricks" (list scoredTrickDecoder)
        |> required "status" statusDecoder


tuple4 : a -> b -> c -> d -> ( a, b, c, d )
tuple4 a b c d =
    ( a, b, c, d )
