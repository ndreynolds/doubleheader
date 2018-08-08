module Socket exposing (initSocket, subscribeToGameUpdates)

import Json.Encode exposing (Value)
import Phoenix.Socket exposing (Socket)


initSocket : Socket msg
initSocket =
    Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
        |> Phoenix.Socket.withDebug


subscribeToGameUpdates : Int -> (Value -> msg) -> Socket msg -> Socket msg
subscribeToGameUpdates gameId msg socket =
    let
        topic =
            "game:" ++ toString gameId
    in
    Phoenix.Socket.on "update" topic msg socket
