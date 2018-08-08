module View exposing (view)

import Html exposing (Html)
import Model exposing (Model, Msg)
import View.Game exposing (gameView)
import View.Lobby exposing (lobbyView)


view : Model -> Html Msg
view model =
    case model.gameState of
        Just gameState ->
            gameView model

        Nothing ->
            lobbyView model
