module Model.Status exposing (Status(..), statusDecoder)

import Json.Decode exposing (Decoder, andThen, fail, field, map2, maybe, string, succeed)
import Model.Player exposing (PlayerName)


type Status
    = AwaitingServer
    | AwaitingPlayers
    | AwaitingBids
    | AwaitingAction PlayerName
    | Decided


statusTupleDecoder : ( String, Maybe String ) -> Decoder Status
statusTupleDecoder status =
    case status of
        ( "awaiting_players", Nothing ) ->
            succeed AwaitingPlayers

        ( "awaiting_bids", Nothing ) ->
            succeed AwaitingBids

        ( "awaiting_action", Just player ) ->
            succeed (AwaitingAction player)

        ( "decided", Nothing ) ->
            succeed Decided

        ( name, _ ) ->
            fail ("invalid status: " ++ name)


statusDecoder : Decoder Status
statusDecoder =
    let
        toTuple =
            map2 (,)
                (field "name" string)
                (field "value" (maybe string))
    in
    toTuple |> andThen statusTupleDecoder
