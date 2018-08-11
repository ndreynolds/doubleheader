module Model.Card exposing (Card, cardDecoder, encodeCard)

import Json.Decode as JD exposing (andThen, fail, field, map2, string, succeed)
import Json.Encode as JE


type alias Card =
    ( Rank, Suit )


type Rank
    = Ace
    | Nine
    | Ten
    | Jack
    | Queen
    | King


type Suit
    = Clubs
    | Diamonds
    | Hearts
    | Spades


encodeCard : Card -> JE.Value
encodeCard ( rank, suit ) =
    let
        rankVal =
            String.toLower (toString rank)

        suitVal =
            String.toLower (toString suit)
    in
    JE.object
        [ ( "rank", JE.string rankVal )
        , ( "suit", JE.string suitVal )
        ]


rankDecoder : String -> JD.Decoder Rank
rankDecoder rank =
    case rank of
        "ace" ->
            succeed Ace

        "nine" ->
            succeed Nine

        "ten" ->
            succeed Ten

        "jack" ->
            succeed Jack

        "queen" ->
            succeed Queen

        "king" ->
            succeed King

        _ ->
            fail ("invalid rank: " ++ rank)


suitDecoder : String -> JD.Decoder Suit
suitDecoder suit =
    case suit of
        "clubs" ->
            succeed Clubs

        "diamonds" ->
            succeed Diamonds

        "hearts" ->
            succeed Hearts

        "spades" ->
            succeed Spades

        _ ->
            fail ("invalid suit: " ++ suit)


cardDecoder : JD.Decoder Card
cardDecoder =
    map2 (,)
        (field "rank" string |> andThen rankDecoder)
        (field "suit" string |> andThen suitDecoder)
