module View.Lobby exposing (lobbyView)

import Html exposing (Html, button, div, h2, input, text)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)
import Material
import Material.Button as Button
import Material.Options as Options
import Material.Textfield as Textfield
import Model exposing (Model, Msg(..))


usernameField : Material.Model -> String -> Html Msg
usernameField mdl username =
    Textfield.render
        Mdl
        [ 1 ]
        mdl
        [ Textfield.label "Enter a username"
        , Textfield.value username
        , Options.onInput SetUsername
        ]
        []


submitBtn : Material.Model -> Html Msg
submitBtn mdl =
    Button.render Mdl
        [ 0 ]
        mdl
        [ Button.raised
        , Button.colored
        , Options.onClick JoinLobby
        ]
        [ text "Play" ]


lobbyView : Model -> Html Msg
lobbyView { mdl, username } =
    div [ class "lobby" ]
        [ div [ class "lobby-inner" ]
            [ h2 [] [ text "Doppelkopf" ]
            , usernameField mdl username
            , submitBtn mdl
            , Html.node "mwc-button" [] [text "Hello"]
            ]
        ]
