module Channel exposing (joinGame, joinLobby, pushGameAction)

import Json.Encode as JE
import Model.GameState exposing (GameId)
import Model.PlayerAction exposing (PlayerAction, encodePlayerAction)
import Phoenix.Channel exposing (Channel)
import Phoenix.Push exposing (Push)


userParams : String -> JE.Value
userParams username =
    JE.object [ ( "username", JE.string username ) ]


joinLobby : String -> (JE.Value -> msg) -> Channel msg
joinLobby username onJoin =
    Phoenix.Channel.init "game:lobby"
        |> Phoenix.Channel.withPayload (userParams username)
        |> Phoenix.Channel.onJoin onJoin


joinGame : String -> (JE.Value -> msg) -> GameId -> Channel msg
joinGame username onJoin gameId =
    Phoenix.Channel.init ("game:" ++ toString gameId)
        |> Phoenix.Channel.withPayload (userParams username)
        |> Phoenix.Channel.onJoin onJoin


pushGameAction : GameId -> PlayerAction -> Push msg
pushGameAction gameId action =
    let
        ( actionType, actionValue ) =
            encodePlayerAction action

        payload =
            JE.object [ ( "value", actionValue ) ]

        event =
            "action:" ++ actionType

        topic =
            "game:" ++ toString gameId
    in
    Phoenix.Push.init event topic
        |> Phoenix.Push.withPayload payload
