defmodule Doppelkopf.GameState do
  @moduledoc """
  A struct that represents the state of a Doppelkopf game at a given point. The
  entire game can be captured as a list of game states.

  This module also implements a finite state machine for transitioning between
  states. Input is regulated via the `status` field, which indicates the type of
  input required to transition to the next state.

  Also of special note is the `type` field, which indicates what type of
  game is being played and may alter the game flow.

  ### Statuses

    :awaiting_players
    :awaiting_bids
    {:awaiting_action, player}
    :decided

  ### Types

    :undetermined
    :normal
    :marriage
    :poverty
    {:solo, solo_type}
  """

  require Logger

  alias __MODULE__
  alias __MODULE__.{Deck, Player, Rules}

  alias Poison.Encoder

  @enforce_keys [
    :id,
    :deck,
    :players,
    :current_trick,
    :scored_tricks,
    :rules,
    :status,
    :type
  ]
  defstruct [:id, :deck, :players, :current_trick, :scored_tricks, :rules, :status, :type]

  defimpl Encoder, for: __MODULE__ do
    def encode(state, opts) do
      Encoder.encode(
        %{
          id: state.id,
          status: status(state.status),
          deck: cards(state.deck),
          players: state.players,
          current_trick: trick(state.current_trick),
          scored_tricks: for(t <- state.scored_tricks, do: scored_trick(t)),
          type: state.type
        },
        opts
      )
    end

    defp trick([]), do: []

    defp trick([{name, crd} | tail]) do
      [%{name: name, card: card(crd)} | trick(tail)]
    end

    defp scored_trick({name, score, complete_trick}) do
      %{name: name, score: score, trick: trick(complete_trick)}
    end

    defp cards([]), do: []
    defp cards([hd | tail]), do: [card(hd) | cards(tail)]

    defp card({rank, suit}), do: %{rank: rank, suit: suit}

    defp status({atom, val}), do: %{name: atom, value: val}
    defp status(atom), do: %{name: atom, value: nil}
  end

  ### Client API

  def new(id) do
    %GameState{
      id: id,
      deck: Deck.standard(),
      players: [],
      current_trick: [],
      scored_tricks: [],
      rules: %Rules{},
      status: :awaiting_players,
      type: :undetermined
    }
  end

  def put_player(%GameState{players: players} = state, name) when length(players) < 4 do
    new_state =
      %GameState{state | players: [Player.new(name) | players]}
      |> transition()

    {:ok, new_state}
  end

  def put_player(_, _) do
    {:error, :invalid_operation}
  end

  def put_bid(%GameState{status: :awaiting_bids} = state, name, bid) do
    new_state =
      state
      |> update_player(name, %{bid: bid})
      |> transition()

    {:ok, new_state}
  end

  def put_bid(_, _, _) do
    {:error, :invalid_operation}
  end

  def put_card(
        %GameState{current_trick: trick, status: {:awaiting_action, name}, rules: rules} =
          state,
        name,
        card
      ) do
    %Player{hand: hand} = Enum.find(state.players, &(&1.name == name))

    with :ok <- Rules.validate_play(rules, trick, hand, {name, card}) do
      new_state =
        %GameState{state | current_trick: [{name, card} | trick]}
        |> update_player(name, %{hand: List.delete(hand, card)})
        |> transition()

      {:ok, new_state}
    end
  end

  def put_card(_state, _name, _card) do
    {:error, :invalid_operation}
  end

  ### Internal State Transitions

  defp transition(%GameState{status: :awaiting_players, players: players} = state)
       when length(players) == 4 do
    %GameState{deal(state) | status: :awaiting_bids}
  end

  defp transition(
         %GameState{
           status: :awaiting_bids,
           type: :undetermined,
           players: [
             %Player{bid: :healthy, name: player_1},
             %Player{bid: :healthy},
             %Player{bid: :healthy},
             %Player{bid: :healthy}
           ]
         } = state
       ) do
    %GameState{state | status: {:awaiting_action, player_1}, type: :normal}
  end

  defp transition(
         %GameState{
           status: {:awaiting_action, name},
           type: :normal,
           players: players,
           current_trick: [{name, _card}, _, _, _] = trick,
           scored_tricks: tricks,
           rules: rules
         } = state
       ) do
    {:ok, trick_winner} = Rules.winner(rules, trick)
    {:ok, trick_score} = Rules.score(rules, trick)

    new_status =
      case Enum.map(players, & &1.hand) do
        [[], [], [], []] ->
          :decided

        _ ->
          {:awaiting_action, trick_winner}
      end

    %GameState{
      state
      | status: new_status,
        scored_tricks: [{trick_winner, trick_score, trick} | tricks],
        current_trick: []
    }
  end

  defp transition(
         %GameState{
           status: {:awaiting_action, name},
           type: :normal,
           players: players,
           current_trick: [{name, _card} | _tail]
         } = state
       ) do
    %GameState{state | status: {:awaiting_action, next_player(players, name)}}
  end

  defp transition(state) do
    Logger.debug("No transition for: " <> inspect(state))
    state
  end

  defp deal(%GameState{deck: deck, players: players} = state) do
    shuffled_deck = Enum.shuffle(deck)

    {dealt_players, empty_deck} =
      Enum.map_reduce(players, shuffled_deck, fn player, acc ->
        {hand, remaining_deck} = Enum.split(acc, 12)
        {%Player{player | hand: hand}, remaining_deck}
      end)

    %GameState{state | players: dealt_players, deck: empty_deck}
  end

  ### Utilities

  defp next_player(players, previous_name) do
    players
    |> Enum.map(& &1.name)
    |> player_after(previous_name)
  end

  defp player_after([p1, p2, _p3, _p4], p1), do: p2
  defp player_after([_p1, p2, p3, _p4], p2), do: p3
  defp player_after([_p1, _p2, p3, p4], p3), do: p4
  defp player_after([p1, _p2, _p3, p4], p4), do: p1

  defp update_player(%GameState{players: players} = state, name, attrs_or_fn) do
    updated_players =
      Enum.map(players, fn
        %Player{name: ^name} = player ->
          cond do
            is_function(attrs_or_fn, 1) ->
              attrs_or_fn.(player)

            is_map(attrs_or_fn) ->
              Map.merge(player, attrs_or_fn)

            true ->
              player
          end

        player ->
          player
      end)

    %GameState{state | players: updated_players}
  end
end
