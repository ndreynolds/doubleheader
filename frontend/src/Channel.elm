module Channel exposing (join, pushGameAction)

import Json.Encode as JE
import Model.GameState exposing (GameId)
import Model.PlayerAction exposing (PlayerAction, encodePlayerAction)
import Phoenix.Channel exposing (Channel)
import Phoenix.Push exposing (Push)


type alias ChannelJoinOptions msg =
    { onJoin : JE.Value -> msg
    , onJoinError : JE.Value -> msg
    , username : String
    , topic : String
    }


userParams : String -> JE.Value
userParams username =
    JE.object [ ( "username", JE.string username ) ]


join : ChannelJoinOptions msg -> Channel msg
join { onJoin, onJoinError, username, topic } =
    Phoenix.Channel.init topic
        |> Phoenix.Channel.withPayload (userParams username)
        |> Phoenix.Channel.onJoin onJoin
        |> Phoenix.Channel.onJoinError onJoinError


pushGameAction : GameId -> PlayerAction -> (JE.Value -> msg) -> Push msg
pushGameAction gameId action onError =
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
        |> Phoenix.Push.onError onError
