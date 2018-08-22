module View.Trick exposing (currentTrickView, scoredTricksView)

import Html exposing (Attribute, Html, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Model.Trick exposing (IncompleteTrick, ScoredTrick)
import View.Card exposing (cardFrontView)
import View.Hand exposing (visibleHandView)


currentTrickView : IncompleteTrick -> Html msg
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


scoredTrickView : ScoredTrick -> Html msg
scoredTrickView ( name, score, ( ( p1, c1 ), ( p2, c2 ), ( p3, c3 ), ( p4, c4 ) ) ) =
    tr []
        [ td [] [ text name ]
        , td [] [ text (toString score) ]
        , td []
            [ visibleHandView [ c1, c2, c3, c4 ]
            ]
        ]


scoredTricksView : List ScoredTrick -> Html msg
scoredTricksView tricks =
    table [ class "table table-striped table-hover" ]
        [ thead []
            [ tr []
                [ th [] [ text "Winner" ]
                , th [] [ text "Points" ]
                , th [] [ text "Trick" ]
                ]
            ]
        , tbody [] (List.map scoredTrickView tricks)
        ]
