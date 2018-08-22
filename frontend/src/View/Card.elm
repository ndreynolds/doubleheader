module View.Card exposing (cardBackView, cardFrontView)

import Html exposing (Attribute, Html, div, img)
import Html.Attributes exposing (class, src, value)
import Model.Card exposing (Card)


cardBaseView : List (Attribute msg) -> List (Attribute msg) -> Card -> Html msg
cardBaseView wrapperAttrs imgAttrs card =
    div ([ class "card" ] ++ wrapperAttrs)
        [ img imgAttrs []
        ]


cardFrontView : List (Attribute msg) -> Card -> Html msg
cardFrontView attrs card =
    let
        ( rank, suit ) =
            card

        imgSrc =
            "/cards/" ++ toString rank ++ "_of_" ++ toString suit ++ ".png"
    in
    cardBaseView attrs [ src imgSrc ] card


cardBackView : List (Attribute msg) -> Card -> Html msg
cardBackView attrs =
    cardBaseView attrs [ src "/cards/back.png" ]
