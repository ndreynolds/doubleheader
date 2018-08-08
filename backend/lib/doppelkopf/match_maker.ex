defmodule Doppelkopf.MatchMaker do
  @moduledoc """
  A registry for connecting players to games. Implemented as a GenServer that
  maintains the list of users and a registry of games and their players.
  """

  use GenServer

  require Logger

  alias Doppelkopf.GameServer

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def register_user(username) do
    GenServer.call(__MODULE__, {:register_user, username})
  end

  def assign_game(username) do
    GenServer.call(__MODULE__, {:assign_game, username})
  end

  def lookup_game(game_id) when is_binary(game_id) do
    case Integer.parse(game_id) do
      {id, _} ->
        lookup_game(id)

      :error ->
        {:error, :invalid_game_id}
    end
  end

  def lookup_game(game_id) do
    GenServer.call(__MODULE__, {:lookup_game, game_id})
  end

  def lookup_game_server(game_id) do
    with {:ok, %{server_pid: pid}} <- lookup_game(game_id) do
      {:ok, pid}
    end
  end

  # Server (callbacks)

  @impl true
  def init(:ok) do
    {:ok, %{users: MapSet.new(), game_counter: 0, games: %{}}}
  end

  @impl true
  def handle_call({:register_user, username}, _from, %{users: users} = state) do
    if MapSet.member?(users, username) do
      {:reply, {:error, :username_taken}, state}
    else
      {:reply, :ok, put_user(state, username)}
    end
  end

  @impl true
  def handle_call({:assign_game, username}, _from, state) do
    case find_or_create_game(state) do
      {:ok, game_id, new_state} ->
        {:reply, {:ok, game_id}, put_player(new_state, username, game_id)}

      {:error, err} ->
        Logger.warn("Error assigning game: " <> err)
        {:reply, {:error, :cannot_assign_game}, state}
    end
  end

  @impl true
  def handle_call({:lookup_game, id}, _from, %{games: games} = state) do
    {:reply, fetch_game(games, id), state}
  end

  defp find_or_create_game(%{games: games, game_counter: counter} = state) do
    case find_open_game(games) do
      {game_id, _game} ->
        {:ok, game_id, state}

      nil ->
        game_id = counter + 1

        with {:ok, game} <- create_game(game_id) do
          new_state = %{
            state
            | games: Map.put(games, game_id, game),
              game_counter: game_id
          }

          {:ok, game_id, new_state}
        end
    end
  end

  defp find_open_game(games) do
    games
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.find(fn {_, %{players: players}} -> length(players) < 4 end)
  end

  defp create_game(id) do
    with {:ok, pid} <- GameServer.start_link(id) do
      {:ok,
       %{
         server_pid: pid,
         players: []
       }}
    end
  end

  defp fetch_game(games, id) do
    case Map.get(games, id) do
      nil ->
        {:error, :not_found}

      game ->
        {:ok, game}
    end
  end

  defp put_player(state, username, game_id) do
    update_in(state, [:games, game_id], fn %{players: players} = game ->
      %{game | players: [username | players]}
    end)
  end

  defp put_user(%{users: users} = state, username) do
    %{state | users: MapSet.put(users, username)}
  end
end
