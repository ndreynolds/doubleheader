module Model.Card exposing (Card, cardDecoder, encodeCard)

import Json.Decode exposing (Decoder, andThen, fail, field, map2, string, succeed)
import Json.Encode exposing (Value, object)


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


encodeCard : Card -> Value
encodeCard ( rank, suit ) =
    let
        rankVal =
            String.toLower (toString rank)

        suitVal =
            String.toLower (toString suit)
    in
    object
        [ ( "rank", Json.Encode.string rankVal )
        , ( "suit", Json.Encode.string suitVal )
        ]


rankDecoder : String -> Decoder Rank
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


suitDecoder : String -> Decoder Suit
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


cardDecoder : Decoder Card
cardDecoder =
    map2 (,)
        (field "rank" string |> andThen rankDecoder)
        (field "suit" string |> andThen suitDecoder)
