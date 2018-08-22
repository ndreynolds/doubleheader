module View.UI
    exposing
        ( ColumnAlignment(..)
        , column
        , errorToast
        , grid
        , tabs
        , toast
        )

import Html exposing (Attribute, Html, a, div, li, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)


type ColumnAlignment
    = Center
    | Left
    | Right
    | None


type alias ColumnOptions =
    { size : Int
    , align : ColumnAlignment
    }


type alias TabOptions msg =
    { selectedIndex : Int
    , onSelect : Int -> msg
    }


grid : List (Attribute msg) -> List (Html msg) -> Html msg
grid attrs columns =
    div (class "container" :: attrs)
        [ div [ class "columns" ] columns ]


column : ColumnOptions -> List (Html msg) -> Html msg
column { size, align } =
    let
        sizeClass =
            "col-" ++ toString size

        alignClass =
            case align of
                Center ->
                    "col-mx-auto"

                Left ->
                    "col-mr-auto"

                Right ->
                    "col-mr-auto"

                None ->
                    ""

        classStr =
            String.join " " [ "column", sizeClass, alignClass ]
    in
    div [ class classStr ]


tabs : TabOptions msg -> List (Html msg) -> Html msg
tabs { selectedIndex, onSelect } labels =
    let
        tab index label =
            li
                [ class "tab-item"
                , classList [ ( "active", index == selectedIndex ) ]
                , onClick (onSelect index)
                ]
                [ a [ href "#" ] [ label ] ]
    in
    ul [ class "tab tab-block" ]
        (List.indexedMap tab labels)


toast : List (Attribute msg) -> List (Html msg) -> Html msg
toast attrs =
    div (class "toast" :: attrs)


errorToast : List (Attribute msg) -> List (Html msg) -> Html msg
errorToast attrs =
    toast (class "toast-error" :: attrs)
