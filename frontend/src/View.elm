module View exposing (view)

import Html exposing (Html, div, h6, text)
import Html.Attributes exposing (class)
import Model exposing (Model, Msg)
import View.Game exposing (tabbedView)
import View.Lobby exposing (lobbyView)
import View.UI as UI exposing (ColumnAlignment(..))


error : String -> Html Msg
error msg =
    UI.errorToast []
        [ h6 [] [ text "Errors" ]
        , text msg
        ]


errors : List String -> List (Html Msg)
errors messages =
    case messages of
        [] ->
            []

        messages ->
            List.map error messages


view : Model -> Html Msg
view model =
    let
        mainView =
            case model.gameState of
                Just gameState ->
                    tabbedView model

                Nothing ->
                    lobbyView model

        ( errorMessages, _ ) =
            List.unzip model.errors
    in
    div []
        [ mainView
        , UI.grid [ class "errors" ]
            [ UI.column { size = 8, align = Center }
                (errors errorMessages)
            ]
        ]
