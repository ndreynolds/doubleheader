defmodule DoppelkopfWeb.GameChannel do
  @moduledoc """
  A channel for the lobby and dedicated game topics. Handles incoming join
  requests and player actions.

  Most of the work is delegated to the `MatchMaker` and the game's `GameServer`.
  """

  use Phoenix.Channel
  require Logger

  alias Phoenix.Socket

  alias Doppelkopf.{GameServer, GameState.Bid, GameState.Card, MatchMaker}

  # TODO: Assign a token after registering the username and require a matching
  # token to join the game as that username. Usernames could be returned to the
  # available pool after so many hours of inactivity.

  # TODO: Rethink game:lobby -> game:<id> flow. Currently the game becomes
  # unplayable if the user is assigned to a game but never joins it. Instead,
  # the server could provide a list of open games and we could make the join
  # a single operation.

  def join("game:lobby", %{"username" => username}, socket) do
    with :ok <- MatchMaker.register_user(username),
         {:ok, game_id} <- MatchMaker.assign_game(username) do
      {:ok, game_id, put_username(socket, username)}
    end
  end

  def join("game:" <> game_id, %{"username" => username}, socket) do
    with {:ok, pid} <- MatchMaker.lookup_game_server(game_id),
         :ok <- GameServer.put_player(pid, username),
         {:ok, game_state} <- GameServer.current_state(pid) do
      {:ok, game_state, put_username(socket, username)}
    end
  end

  def handle_in(
        "action:" <> action_type,
        %{"value" => value},
        %Socket{
          topic: "game:" <> game_id,
          assigns: %{username: username}
        } = socket
      ) do
    with {:ok, pid} <- MatchMaker.lookup_game_server(game_id),
         :ok <- handle_action(action_type, pid, username, value) do
      {:reply, :ok, socket}
    else
      {:error, err} ->
        Logger.warn("Error in handle_in: " <> inspect(err))
        {:reply, {:error, %{reason: err}}, socket}
    end
  end

  defp handle_action("bid", server_pid, username, value) do
    with {:ok, bid} <- Bid.parse(value) do
      GameServer.put_bid(server_pid, username, bid)
    end
  end

  defp handle_action("play", server_pid, username, value) do
    with {:ok, card} <- Card.parse(value) do
      GameServer.put_card(server_pid, username, card)
    end
  end

  defp handle_action(_type, _server_pid, _username, _value) do
    {:error, :unhandled_action}
  end

  defp put_username(socket, username) do
    assign(socket, :username, username)
  end
end
