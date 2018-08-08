module View.Game exposing (gameView)

import Html exposing (Attribute, Html, button, div, h1, h2, img, input, table, td, text, tr)
import Html.Attributes exposing (class, src, value)
import Html.Events exposing (onClick, onInput)
import Material.Table as Table
import Material.Tabs as Tabs
import Model exposing (Model, Msg(..))
import Model.Card exposing (Card)
import Model.GameState exposing (GameState, availableActions)
import Model.Player exposing (Player)
import Model.PlayerAction exposing (PlayerAction(..))
import Model.Status exposing (Status)
import Model.Trick exposing (IncompleteTrick, ScoredTrick)


cardBaseView : List (Attribute Msg) -> List (Attribute Msg) -> Card -> Html Msg
cardBaseView wrapperAttrs imgAttrs card =
    div ([ class "card" ] ++ wrapperAttrs)
        [ img imgAttrs []
        ]


cardFrontView : List (Attribute Msg) -> Card -> Html Msg
cardFrontView attrs card =
    let
        ( rank, suit ) =
            card

        imgSrc =
            "/cards/" ++ toString rank ++ "_of_" ++ toString suit ++ ".png"
    in
    cardBaseView attrs [ src imgSrc ] card


cardBackView : List (Attribute Msg) -> Card -> Html Msg
cardBackView attrs card =
    cardBaseView attrs [ src "/cards/back.png" ] card


concealedHandView : List Card -> Html Msg
concealedHandView hand =
    div [ class "hand" ] (List.map (\c -> cardBackView [] c) hand)


visibleHandView : List Card -> Html Msg
visibleHandView hand =
    div [ class "hand" ] (List.map (\c -> cardFrontView [] c) hand)


activeHandView : List Card -> Html Msg
activeHandView hand =
    div [ class "hand" ] (List.map (\c -> cardFrontView [ onClick (Action (Play c)), class "selectable" ] c) hand)


deckView : List Card -> Html Msg
deckView deck =
    div [ class "deck" ] (List.map (\c -> cardBackView [] c) deck)


playerView : Maybe Player -> String -> Html Msg
playerView player username =
    case player of
        Just { name, hand, score } ->
            let
                scoreText =
                    " (" ++ toString score ++ ")"

                handView_ =
                    if name == username then
                        activeHandView hand
                    else
                        concealedHandView hand
            in
            div [ class "player" ]
                [ handView_
                , div [ class "name" ] [ text name, text scoreText ]
                ]

        Nothing ->
            div [ class "player" ]
                [ div [ class "name" ] [ text "Empty Seat" ]
                ]


actionView : PlayerAction -> Html Msg
actionView action =
    button [ onClick (Action action) ] [ text (toString action) ]


actionsView : Maybe Player -> Status -> Html Msg
actionsView player status =
    let
        statusText =
            toString status

        actions =
            case player of
                Just player ->
                    availableActions player status

                Nothing ->
                    []
    in
    div [ class "actions" ]
        ([ text statusText ]
            ++ List.map actionView actions
        )


currentTrickView : IncompleteTrick -> Html Msg
currentTrickView ( a, b, c, d ) =
    let
        maybeCardView card =
            case card of
                Just card ->
                    cardFrontView [] card

                Nothing ->
                    div [] []
    in
    div [ class "trick" ]
        [ maybeCardView (Maybe.map Tuple.second d)
        , maybeCardView (Maybe.map Tuple.second c)
        , maybeCardView (Maybe.map Tuple.second b)
        , maybeCardView (Maybe.map Tuple.second a)
        ]


scoredTrickView : ScoredTrick -> Html Msg
scoredTrickView ( name, score, ( ( p1, c1 ), ( p2, c2 ), ( p3, c3 ), ( p4, c4 ) ) ) =
    Table.tr []
        [ Table.td [] [ text name ]
        , Table.td [ Table.numeric ] [ text (toString score) ]
        , Table.td []
            [ visibleHandView [ c1, c2, c3, c4 ]
            ]
        ]


scoredTricksView : List ScoredTrick -> Html Msg
scoredTricksView tricks =
    Table.table []
        [ Table.thead []
            [ Table.tr []
                [ Table.th [] [ text "Winner" ]
                , Table.th [] [ text "Score" ]
                , Table.th [] [ text "Trick" ]
                ]
            ]
        , Table.tbody [] (List.map scoredTrickView tricks)
        ]


hasName : Maybe Player -> String -> Bool
hasName maybePlayer name =
    case maybePlayer of
        Just player ->
            player.name == name

        Nothing ->
            False


arrangePlayers :
    ( Maybe Player, Maybe Player, Maybe Player, Maybe Player )
    -> String
    -> ( Maybe Player, ( Maybe Player, Maybe Player, Maybe Player, Maybe Player ) )
arrangePlayers ( a, b, c, d ) username =
    if hasName a username then
        ( a, ( b, c, d, a ) )
    else if hasName b username then
        ( b, ( c, d, a, b ) )
    else if hasName c username then
        ( c, ( d, a, b, c ) )
    else
        ( d, ( a, b, c, d ) )


tableView : GameState -> String -> Html Msg
tableView { deck, currentTrick, players, status } username =
    let
        ( currentPlayer, ( p1, p2, p3, p4 ) ) =
            arrangePlayers players username
    in
    div
        [ class "game" ]
        [ div [ class "table" ]
            [ div [ class "table-top" ]
                [ playerView p2 username ]
            , div [ class "table-center" ]
                [ playerView p1 username
                , deckView deck
                , currentTrickView currentTrick
                , playerView p3 username
                ]
            , div [ class "table-bottom" ]
                [ playerView currentPlayer username ]
            ]
        , actionsView currentPlayer status
        ]


gameView : Model -> Html Msg
gameView model =
    Tabs.render Mdl
        [ 0 ]
        model.mdl
        [ Tabs.ripple
        , Tabs.onSelectTab SelectTab
        , Tabs.activeTab model.tab
        ]
        [ Tabs.label
            []
            [ text "Game" ]
        , Tabs.label
            []
            [ text "Tricks" ]
        ]
        [ case ( model.gameState, model.tab ) of
            ( Just gameState, 0 ) ->
                tableView gameState model.username

            ( Just gameState, 1 ) ->
                scoredTricksView gameState.scoredTricks

            _ ->
                div [] []
        ]
