module Model exposing (Model, Msg(..), init)

import Json.Encode as JE
import Material
import Model.GameState exposing (GameState)
import Model.PlayerAction exposing (PlayerAction)
import Phoenix.Socket
import Socket exposing (initSocket)


type Msg
    = SocketMessage (Phoenix.Socket.Msg Msg)
    | NewGameState JE.Value
    | JoinLobby
    | JoinGame Int
    | SetUsername String
    | Action PlayerAction
    | ShowError String
    | SelectTab Int
    | Mdl (Material.Msg Msg)


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , gameState : Maybe GameState
    , username : String
    , registered : Bool
    , tab : Int
    , mdl : Material.Model
    }


init : ( Model, Cmd Msg )
init =
    ( { gameState = Nothing
      , socket = initSocket
      , username = ""
      , registered = False
      , tab = 0
      , mdl = Material.model
      }
    , Cmd.none
    )
