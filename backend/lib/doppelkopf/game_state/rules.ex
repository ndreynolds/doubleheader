defmodule Doppelkopf.GameState.Rules do
  @moduledoc """
  A struct for configuring the game rules and logic to validate and score plays.

  There are many regional variations of the game with adjusted rules. For
  example, in the standard game, when the exact same card is played twice in one
  trick, the first played is ranked higher. One variation makes an exception to
  this rule for the ten of hearts. This forces players to use the ten of hearts
  more strategically, as there's the danger of the second ten of hearts.

  The goal of this module is to eventually support most of these variations.
  Functions take a %Rules{} struct as first argument and based on the passed
  rule set, a given play could be scored or validated differently.

  So far, only the standard configuration is supported.
  """

  # TODO: Add additional variations.
  defstruct second_10h: false,
            piglets: false

  @trumps_ranking [
    {:ten, :hearts},
    {:queen, :clubs},
    {:queen, :spades},
    {:queen, :hearts},
    {:queen, :diamonds},
    {:jack, :clubs},
    {:jack, :spades},
    {:jack, :hearts},
    {:jack, :diamonds},
    {:ace, :diamonds},
    {:ten, :diamonds},
    {:king, :diamonds},
    {:nine, :diamonds}
  ]

  @color_ranking [
    :ace,
    :ten,
    :king,
    :nine
  ]

  @point_values [
    ace: 11,
    ten: 10,
    king: 4,
    queen: 3,
    jack: 2,
    nine: 0
  ]

  def score(_rules, trick) when length(trick) == 4 do
    score =
      trick
      |> Enum.map(fn {_name, {rank, _suit}} -> @point_values[rank] end)
      |> Enum.sum()

    {:ok, score}
  end

  def score(_rules, _trick) do
    {:error, :incomplete_trick}
  end

  def winner(rules, [_, _, _, {_name, follow}] = trick) do
    {{winner, _card}, _index} =
      trick
      |> Enum.zip(4..1)
      |> Enum.sort_by(&rank(rules, follow, &1))
      |> List.first()

    {:ok, winner}
  end

  def winner(_rules, _trick) do
    {:error, :incomplete_trick}
  end

  defp rank(rules, follow, {{_name, card}, index}) do
    {
      ranking(rules, kind(rules, follow), kind(rules, card), card),
      index
    }
  end

  defp ranking(_rules, :trump, :trump, card) do
    Enum.find_index(@trumps_ranking, &(&1 == card))
  end

  defp ranking(_rules, :trump, _other, _card) do
    100
  end

  defp ranking(_rules, {:color, _follow_suit}, :trump, card) do
    Enum.find_index(@trumps_ranking, &(&1 == card))
  end

  defp ranking(_rules, {:color, follow_suit}, {:color, follow_suit}, {rank, _suit}) do
    Enum.find_index(@color_ranking, &(&1 == rank)) + 50
  end

  defp ranking(_rules, {:color, _follow_suit}, {:color, _other_suit}, {rank, _suit}) do
    Enum.find_index(@color_ranking, &(&1 == rank)) + 100
  end

  def validate_play(rules, trick, hand, {name, card}) when length(trick) < 4 do
    cond do
      card not in hand ->
        {:error, :not_in_hand}

      name in Keyword.keys(trick) ->
        {:error, :already_played}

      true ->
        case trick do
          [] ->
            :ok

          [{_name, follow}] ->
            validate_follow(rules, hand, follow, card)

          [_, {_name, follow}] ->
            validate_follow(rules, hand, follow, card)

          [_, _, {_name, follow}] ->
            validate_follow(rules, hand, follow, card)
        end
    end
  end

  def validate_play(_rules, _trick, _, _) do
    {:error, :full_trick}
  end

  defp validate_follow(rules, hand, follow, card) do
    case {kind(rules, follow), kind(rules, card)} do
      {:trump, :trump} ->
        :ok

      {{:color, suit}, {:color, suit}} ->
        :ok

      {follow_kind, _} ->
        if can_follow?(rules, hand, follow_kind),
          do: {:error, :must_follow},
          else: :ok
    end
  end

  defp can_follow?(rules, hand, :trump) do
    Enum.any?(hand, &trump?(rules, &1))
  end

  defp can_follow?(rules, hand, {:color, suit}) do
    Enum.any?(hand, fn
      {_rank, ^suit} = card -> color?(rules, card)
      _ -> false
    end)
  end

  defp kind(rules, {_rank, suit} = card) do
    if trump?(rules, card), do: :trump, else: {:color, suit}
  end

  defp color?(rules, card), do: not trump?(rules, card)

  defp trump?(_rules, {_rank, :diamonds}), do: true
  defp trump?(_rules, {:ten, :hearts}), do: true
  defp trump?(_rules, {rank, _suit}) when rank in [:queen, :jack], do: true
  defp trump?(_rules, _card), do: false
end
