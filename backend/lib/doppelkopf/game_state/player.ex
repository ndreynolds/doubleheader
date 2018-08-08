defmodule Doppelkopf.GameState.Player do
  @moduledoc """
  Represents a player within the game.
  """

  alias __MODULE__
  alias Poison.Encoder

  @enforce_keys [:name, :score, :bid, :hand]
  defstruct [:name, :score, :bid, :hand]

  defimpl Encoder, for: __MODULE__ do
    def encode(struct, opts) do
      Encoder.encode(
        %{
          name: struct.name,
          score: struct.score,
          bid: struct.bid,
          hand: Enum.map(struct.hand, &card/1)
        },
        opts
      )
    end

    defp card({rank, suit}), do: %{rank: rank, suit: suit}
  end

  def new(name) do
    %Player{name: name, score: 0, bid: nil, hand: []}
  end
end
