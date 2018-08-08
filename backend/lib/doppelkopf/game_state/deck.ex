defmodule Doppelkopf.GameState.Deck do
  @moduledoc """
  Utilities for building Doppelkopf decks.
  """

  alias Doppelkopf.GameState.Card

  def standard do
    for rank <- Card.ranks(),
        suit <- Card.suits(),
        _ <- 1..2 do
      {rank, suit}
    end
  end
end
