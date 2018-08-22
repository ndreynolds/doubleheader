module View.Hand exposing (activeHandView, concealedHandView, visibleHandView)

import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Card exposing (Card)
import View.Card exposing (cardBackView, cardFrontView)


handContainer : List (Html msg) -> Html msg
handContainer =
    div [ class "hand" ]


concealedHandView : List Card -> Html msg
concealedHandView hand =
    handContainer (List.map (cardBackView []) hand)


visibleHandView : List Card -> Html msg
visibleHandView hand =
    handContainer (List.map (cardFrontView []) hand)


activeHandView : (Card -> msg) -> List Card -> Html msg
activeHandView onSelect hand =
    handContainer
        (List.map
            (\c ->
                cardFrontView [ onClick (onSelect c), class "selectable" ] c
            )
            hand
        )
