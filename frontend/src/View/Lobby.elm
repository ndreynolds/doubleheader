module View.Lobby exposing (lobbyView)

import Html exposing (Html, button, div, h2, input, text)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model, Msg(..))
import View.UI as UI exposing (ColumnAlignment(..))


usernameField : String -> Html Msg
usernameField username =
    input
        [ onInput SetUsername
        , value username
        , placeholder "Enter a username..."
        , class "form-input"
        ]
        []


submitBtn : Html Msg
submitBtn =
    button
        [ onClick JoinLobby
        , class "btn btn-primary input-group-btn"
        ]
        [ text "Play" ]


lobbyView : Model -> Html Msg
lobbyView { username } =
    UI.grid []
        [ UI.column { size = 6, align = Center }
            [ div [ class "panel" ]
                [ div [ class "panel-header" ] [ h2 [] [ text "Doppelkopf" ] ]
                , div [ class "panel-footer" ]
                    [ div [ class "input-group" ]
                        [ usernameField username
                        , submitBtn
                        ]
                    ]
                ]
            ]
        ]
