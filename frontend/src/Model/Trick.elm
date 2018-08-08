module Model.Trick
    exposing
        ( CompleteTrick
        , IncompleteTrick
        , ScoredTrick
        , incompleteTrickDecoder
        , scoredTrickDecoder
        )

import Json.Decode exposing (Decoder, field, index, int, map2, map3, map4, maybe, string)
import Model.Card exposing (Card, cardDecoder)
import Model.Player exposing (PlayerName)


type alias IncompleteTrick =
    ( Maybe TrickPart, Maybe TrickPart, Maybe TrickPart, Maybe TrickPart )


type alias CompleteTrick =
    ( TrickPart, TrickPart, TrickPart, TrickPart )


type alias ScoredTrick =
    ( PlayerName, Int, CompleteTrick )


type alias TrickPart =
    ( PlayerName, Card )


trickPartDecoder : Decoder TrickPart
trickPartDecoder =
    map2 (,)
        (field "name" string)
        (field "card" cardDecoder)


completeTrickDecoder : Decoder CompleteTrick
completeTrickDecoder =
    map4 tuple4
        (index 0 trickPartDecoder)
        (index 1 trickPartDecoder)
        (index 2 trickPartDecoder)
        (index 3 trickPartDecoder)


incompleteTrickDecoder : Decoder IncompleteTrick
incompleteTrickDecoder =
    map4 tuple4
        (maybe (index 0 trickPartDecoder))
        (maybe (index 1 trickPartDecoder))
        (maybe (index 2 trickPartDecoder))
        (maybe (index 3 trickPartDecoder))


scoredTrickDecoder : Decoder ScoredTrick
scoredTrickDecoder =
    map3 tuple3
        (field "name" string)
        (field "score" int)
        (field "trick" completeTrickDecoder)


tuple3 : a -> b -> c -> ( a, b, c )
tuple3 a b c =
    ( a, b, c )


tuple4 : a -> b -> c -> d -> ( a, b, c, d )
tuple4 a b c d =
    ( a, b, c, d )
