module Model exposing (Model, Msg(..), init)

import Model.GameState exposing (GameState)
import Model.PlayerAction exposing (PlayerAction)
import Phoenix.Socket exposing (Socket)
import Time exposing (Time)


type Msg
    = SocketMessage (Phoenix.Socket.Msg Msg)
    | NewGameState GameState
    | JoinLobby
    | LeaveLobby String
    | JoinGame Int
    | SetUsername String
    | Action PlayerAction
    | ShowError String
    | ExpireErrors
    | SelectTab Int


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , gameState : Maybe GameState
    , username : String
    , registered : Bool
    , tab : Int
    , errors : List ( String, Time )
    }


initSocket : Socket Msg
initSocket =
    Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
        |> Phoenix.Socket.withDebug


init : ( Model, Cmd Msg )
init =
    ( { gameState = Nothing
      , socket = initSocket
      , username = ""
      , registered = False
      , tab = 0
      , errors = []
      }
    , Cmd.none
    )
