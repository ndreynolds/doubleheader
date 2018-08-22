module View.Game exposing (tabbedView)

import Html exposing (Attribute, Html, a, button, div, li, text, ul)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Model exposing (Model, Msg(..))
import Model.Card exposing (Card)
import Model.GameState exposing (GameState, PlayerTuple, availableActions)
import Model.Player exposing (Player)
import Model.PlayerAction exposing (PlayerAction(..))
import Model.Status exposing (Status)
import View.Card exposing (cardBackView)
import View.Hand exposing (activeHandView, concealedHandView)
import View.Trick exposing (currentTrickView, scoredTricksView)
import View.UI as UI


deckView : List Card -> Html Msg
deckView deck =
    div [ class "deck" ] (List.map (cardBackView []) deck)


playerView : Maybe Player -> Bool -> Html Msg
playerView player active =
    let
        handView =
            if active then
                activeHandView (\c -> Action (Play c))
            else
                concealedHandView

        ( hand, name, score ) =
            case player of
                Just { name, hand, score } ->
                    ( hand, name, score )

                Nothing ->
                    ( [], "Empty Seat", 0 )

        label =
            toString name ++ " (" ++ toString score ++ ")"
    in
    div [ class "player" ]
        [ handView hand
        , div [ class "name" ] [ text label ]
        ]


actionView : PlayerAction -> Html Msg
actionView action =
    li [ class "menu-item" ]
        [ a [ href "#", onClick (Action action) ] [ text (toString action) ]
        ]


actionsView : Maybe Player -> Status -> Html Msg
actionsView player status =
    let
        actions =
            case player of
                Just player ->
                    availableActions player status

                Nothing ->
                    []

        header =
            li [ class "menu-item" ]
                [ div [ class "tile tile-centered" ]
                    [ div [ class "tile-content" ] [ text (toString status) ]
                    ]
                ]

        divider =
            li [ class "divider" ] []
    in
    ul [ class "actions menu" ]
        (header :: divider :: List.map actionView actions)


hasName : Maybe Player -> String -> Bool
hasName maybePlayer name =
    case maybePlayer of
        Just player ->
            player.name == name

        Nothing ->
            False


arrangePlayers : PlayerTuple -> String -> ( Maybe Player, PlayerTuple )
arrangePlayers ( a, b, c, d ) username =
    if hasName a username then
        ( a, ( b, c, d, a ) )
    else if hasName b username then
        ( b, ( c, d, a, b ) )
    else if hasName c username then
        ( c, ( d, a, b, c ) )
    else
        ( d, ( a, b, c, d ) )


cardTableView : PlayerTuple -> Html Msg -> Html Msg
cardTableView ( p1, p2, p3, currentPlayer ) centerpiece =
    let
        topSeat =
            playerView p2 False

        leftSeat =
            playerView p1 False

        rightSeat =
            playerView p3 False

        bottomSeat =
            playerView currentPlayer True
    in
    div [ class "card-table" ]
        [ div [ class "card-table-top" ]
            [ topSeat ]
        , div [ class "card-table-center" ]
            [ leftSeat
            , div [ class "center" ] [ centerpiece ]
            , rightSeat
            ]
        , div [ class "card-table-bottom" ]
            [ bottomSeat ]
        ]


gameView : GameState -> String -> Html Msg
gameView { deck, currentTrick, players, status } username =
    let
        ( currentPlayer, arrangedPlayers ) =
            arrangePlayers players username

        centerpiece =
            if List.isEmpty deck then
                currentTrickView currentTrick
            else
                deckView deck
    in
    div
        [ class "game" ]
        [ cardTableView arrangedPlayers centerpiece
        , actionsView currentPlayer status
        ]


tabbedView : Model -> Html Msg
tabbedView model =
    div []
        [ UI.tabs
            { selectedIndex = model.tab, onSelect = SelectTab }
            [ text "Game"
            , text "Tricks"
            ]
        , case ( model.gameState, model.tab ) of
            ( Just gameState, 0 ) ->
                gameView gameState model.username

            ( Just gameState, 1 ) ->
                scoredTricksView gameState.scoredTricks

            _ ->
                div [] []
        ]
