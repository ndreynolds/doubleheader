defmodule Doppelkopf.GameState.Card do
  @moduledoc """
  Parsing and definition of cards. Represents the playing cards used in a
  Doppelkopf deck.
  """

  @ranks [
    :ace,
    :nine,
    :ten,
    :jack,
    :queen,
    :king
  ]

  @suits [
    :clubs,
    :diamonds,
    :hearts,
    :spades
  ]

  @rank_strings Enum.map(@ranks, &Atom.to_string/1)
  @suit_strings Enum.map(@suits, &Atom.to_string/1)

  def parse(%{"rank" => rank, "suit" => suit})
      when rank in @rank_strings and suit in @suit_strings do
    {:ok,
     {
       String.to_existing_atom(rank),
       String.to_existing_atom(suit)
     }}
  end

  def parse(_) do
    {:error, :invalid}
  end

  def ranks, do: @ranks
  def suits, do: @suits
end
