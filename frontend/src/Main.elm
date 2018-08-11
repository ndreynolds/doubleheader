module Main exposing (..)

import Channel
import Html
import Json.Decode as JD
import Json.Encode as JE
import Material
import Model exposing (Model, Msg(..), init)
import Model.GameState exposing (gameIdDecoder, gameStateDecoder)
import Phoenix.Socket
import View exposing (view)


onJoinLobby : JE.Value -> Msg
onJoinLobby response =
    case JD.decodeValue gameIdDecoder response of
        Ok gameId ->
            JoinGame gameId

        Err error ->
            ShowError error


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
                    Channel.joinLobby model.username onJoinLobby

                ( socket, cmd ) =
                    Phoenix.Socket.join channel model.socket
            in
            ( { model | socket = socket }, Cmd.map SocketMessage cmd )

        JoinGame gameId ->
            let
                channel =
                    Channel.joinGame model.username onNewGameState gameId

                topic =
                    "game:" ++ toString gameId

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
                                |> Phoenix.Socket.push (Channel.pushGameAction id action)
                    in
                    ( { model | socket = socket }, Cmd.map SocketMessage cmd )

                Nothing ->
                    update (ShowError "Action fired without an active game") model

        NewGameState gameState ->
            ( { model | gameState = Just gameState }, Cmd.none )

        ShowError error ->
            Debug.log error
                ( model, Cmd.none )

        SelectTab idx ->
            ( { model | tab = idx }, Cmd.none )

        Mdl msg ->
            Material.update Mdl msg model


subscriptions : Model -> Sub Msg
subscriptions { socket } =
    Phoenix.Socket.listen socket SocketMessage


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
