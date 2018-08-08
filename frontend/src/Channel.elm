module Channel exposing (joinGame, joinLobby, pushGameAction)

import Json.Encode exposing (Value)
import Model.GameState exposing (GameId)
import Model.PlayerAction exposing (PlayerAction, encodePlayerAction)
import Phoenix.Channel exposing (Channel)
import Phoenix.Push exposing (Push)


joinLobby : Value -> (Value -> msg) -> Channel msg
joinLobby userParams onJoin =
    Phoenix.Channel.init "game:lobby"
        |> Phoenix.Channel.withPayload userParams
        |> Phoenix.Channel.onJoin onJoin


joinGame : GameId -> Value -> (Value -> msg) -> Channel msg
joinGame gameId userParams onJoin =
    Phoenix.Channel.init ("game:" ++ toString gameId)
        |> Phoenix.Channel.withPayload userParams
        |> Phoenix.Channel.onJoin onJoin


pushGameAction : GameId -> PlayerAction -> Push msg
pushGameAction gameId action =
    let
        ( actionType, actionValue ) =
            encodePlayerAction action

        payload =
            Json.Encode.object [ ( "value", actionValue ) ]

        event =
            "action:" ++ actionType

        topic =
            "game:" ++ toString gameId
    in
    Phoenix.Push.init event topic
        |> Phoenix.Push.withPayload payload
