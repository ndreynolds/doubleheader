module Main exposing (..)

import Channel
import Html
import Json.Decode as JD
import Json.Encode as JE
import Material
import Model exposing (Model, Msg(..), init)
import Model.GameState exposing (gameIdDecoder, gameStateDecoder)
import Phoenix.Socket
import Socket exposing (initSocket)
import View exposing (view)


---- MODEL ----
---- UPDATE ----


userParams : String -> JE.Value
userParams username =
    JE.object [ ( "username", JE.string username ) ]


onJoinLobby : JE.Value -> Msg
onJoinLobby response =
    case JD.decodeValue gameIdDecoder response of
        Ok gameId ->
            JoinGame gameId

        Err error ->
            ShowError error


onJoinGame : JE.Value -> Msg
onJoinGame response =
    NewGameState response


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
                    Channel.joinLobby (userParams model.username) onJoinLobby

                ( socket, cmd ) =
                    Phoenix.Socket.join channel model.socket
            in
            ( { model | socket = socket }, Cmd.map SocketMessage cmd )

        JoinGame gameId ->
            let
                channel =
                    Channel.joinGame gameId (userParams model.username) onJoinGame

                ( socket, cmd ) =
                    Phoenix.Socket.join channel model.socket

                newSocket =
                    Socket.subscribeToGameUpdates gameId NewGameState socket
            in
            ( { model | socket = newSocket }, Cmd.map SocketMessage cmd )

        Action action ->
            case model.gameState of
                Just gameState ->
                    let
                        push =
                            Channel.pushGameAction gameState.id action

                        ( socket, cmd ) =
                            Phoenix.Socket.push push model.socket
                    in
                    ( { model | socket = socket }, Cmd.map SocketMessage cmd )

                Nothing ->
                    update (ShowError "Action fired without an active game") model

        NewGameState raw ->
            case JD.decodeValue gameStateDecoder raw of
                Ok gameState ->
                    ( { model | gameState = Just gameState }, Cmd.none )

                Err error ->
                    update (ShowError error) model

        ShowError error ->
            Debug.log error
                ( model, Cmd.none )

        SelectTab idx ->
            ( { model | tab = idx }, Cmd.none )

        Mdl msg ->
            Material.update Mdl msg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.socket SocketMessage


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
