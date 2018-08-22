module Main exposing (..)

import Channel
import Html
import Json.Decode as JD
import Json.Encode as JE
import Model exposing (Model, Msg(..), init)
import Model.GameState exposing (gameIdDecoder, gameStateDecoder)
import Phoenix.Socket
import Time
import View exposing (view)


onJoinLobby : JE.Value -> Msg
onJoinLobby response =
    case JD.decodeValue gameIdDecoder response of
        Ok gameId ->
            JoinGame gameId

        Err error ->
            ShowError error


onJoinLobbyError : JE.Value -> Msg
onJoinLobbyError response =
    case JD.decodeValue JD.string response of
        Ok error ->
            LeaveLobby error

        Err parseError ->
            LeaveLobby parseError


onServerError : JE.Value -> Msg
onServerError response =
    let
        errorDecoder =
            JD.field "reason" JD.string

        msg =
            case JD.decodeValue errorDecoder response of
                Ok error ->
                    error

                Err parseError ->
                    parseError
    in
    ShowError msg


onNewGameState : JE.Value -> Msg
onNewGameState response =
    case JD.decodeValue gameStateDecoder response of
        Ok gameState ->
            NewGameState gameState

        Err error ->
            ShowError error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketMessage msg ->
            let
                ( socket, cmd ) =
                    Phoenix.Socket.update msg model.socket
            in
            ( { model | socket = socket }, Cmd.map SocketMessage cmd )

        SetUsername username ->
            ( { model | username = username }, Cmd.none )

        JoinLobby ->
            let
                channel =
                    Channel.join
                        { onJoin = onJoinLobby
                        , onJoinError = onServerError
                        , username = model.username
                        , topic = "game:lobby"
                        }

                ( socket, cmd ) =
                    Phoenix.Socket.join channel model.socket
            in
            ( { model | socket = socket }, Cmd.map SocketMessage cmd )

        LeaveLobby error ->
            let
                ( socket, cmd ) =
                    Phoenix.Socket.leave "game:lobby" model.socket

                errors =
                    ( error, Time.inSeconds 3 ) :: model.errors
            in
            ( { model | socket = socket, errors = errors }, Cmd.map SocketMessage cmd )

        JoinGame gameId ->
            let
                topic =
                    "game:" ++ toString gameId

                channel =
                    Channel.join
                        { onJoin = onNewGameState
                        , onJoinError = onServerError
                        , username = model.username
                        , topic = topic
                        }

                ( socket, cmd ) =
                    model.socket
                        |> Phoenix.Socket.on "update" topic onNewGameState
                        |> Phoenix.Socket.join channel
            in
            ( { model | socket = socket }, Cmd.map SocketMessage cmd )

        Action action ->
            case model.gameState of
                Just { id } ->
                    let
                        ( socket, cmd ) =
                            model.socket
                                |> Phoenix.Socket.push (Channel.pushGameAction id action onServerError)
                    in
                    ( { model | socket = socket }, Cmd.map SocketMessage cmd )

                Nothing ->
                    update (ShowError "Action fired without an active game") model

        NewGameState gameState ->
            ( { model | gameState = Just gameState }, Cmd.none )

        ShowError error ->
            ( { model | errors = ( error, Time.inSeconds 3 ) :: model.errors }, Cmd.none )

        ExpireErrors ->
            let
                decrementOrExpire ( msg, counter ) =
                    if counter > 0 then
                        Just ( msg, counter - 1 )
                    else
                        Nothing

                errors =
                    List.filterMap decrementOrExpire model.errors
            in
            ( { model | errors = errors }, Cmd.none )

        SelectTab idx ->
            ( { model | tab = idx }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        socketListener =
            Phoenix.Socket.listen model.socket SocketMessage

        errorTimer =
            Time.every Time.second (always ExpireErrors)
    in
    Sub.batch [ socketListener, errorTimer ]


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
