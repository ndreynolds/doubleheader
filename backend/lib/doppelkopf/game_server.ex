defmodule Doppelkopf.GameServer do
  @moduledoc """
  Holds the state for a single game of Doppelkopf and provides operations to
  update and broadcast that state.
  """

  # TODO: Games should be recoverable if the server crashes. Consider saving the
  #   state somewhere.

  # TODO: Consider a more generic subscription strategy. I.e., instead of
  #   broadcasting via the endpoint directly, maybe just `send/2` to configured
  #   subscribers. The AI players could later be implemented as separate
  #   processes that interact with the server in a similar way as the players do
  #   (but directly instead of via a phoenix channel).

  use GenServer
  require Logger

  alias Doppelkopf.GameState
  alias DoppelkopfWeb.Endpoint

  # Client

  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  def current_state(pid) do
    GenServer.call(pid, :current_state)
  end

  def put_player(pid, username) do
    GenServer.call(pid, {:put_player, username})
  end

  def put_bid(pid, username, bid) do
    GenServer.call(pid, {:put_bid, username, bid})
  end

  def put_card(pid, username, card) do
    GenServer.call(pid, {:put_card, username, card})
  end

  # Server (callbacks)

  @impl true
  def init(id) do
    {:ok, GameState.new(id)}
  end

  @impl true
  def handle_call(:current_state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  @impl true
  def handle_call({:put_player, username}, _from, state) do
    case GameState.put_player(state, username) do
      {:ok, new_state} ->
        schedule_broadcast_state()
        {:reply, :ok, new_state}

      {:error, _} = err ->
        {:reply, err, state}
    end
  end

  @impl true
  def handle_call({:put_bid, username, bid}, _from, state) do
    case GameState.put_bid(state, username, bid) do
      {:ok, new_state} ->
        schedule_broadcast_state()
        {:reply, :ok, new_state}

      {:error, _} = err ->
        {:reply, err, state}
    end
  end

  @impl true
  def handle_call({:put_card, username, card}, _from, state) do
    case GameState.put_card(state, username, card) do
      {:ok, new_state} ->
        schedule_broadcast_state()
        {:reply, :ok, new_state}

      {:error, _} = err ->
        {:reply, err, state}
    end
  end

  @impl true
  def handle_info(:broadcast_state, state) do
    broadcast_state(state)
    {:noreply, state}
  end

  defp schedule_broadcast_state(after_ms \\ 50) do
    Process.send_after(self(), :broadcast_state, after_ms)
  end

  defp broadcast_state(%GameState{id: id} = state) do
    Endpoint.broadcast!("game:#{id}", "update", state)
  end
end
