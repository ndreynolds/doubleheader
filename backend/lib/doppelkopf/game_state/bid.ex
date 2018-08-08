defmodule Doppelkopf.GameState.Bid do
  @moduledoc """
  Parsers for a bid (Vorbehalt). The four player bids determine the game type.
  """

  def parse("healthy") do
    {:ok, :healthy}
  end

  def parse("marriage") do
    {:ok, :marriage}
  end

  def parse(_) do
    {:error, :invalid}
  end
end
