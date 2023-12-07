defmodule Aoc2023.Day7.Hand do
  defstruct [
    cards: [],
    bid: 0
  ]
end

defmodule Aoc2023.Day7 do
  alias Aoc2023.Day7.Hand

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_hand/1)
  end

  defp parse_hand(line) do
    [cards, bid] =
      line
      |> String.split(" ", trim: true)

    cards = cards |> String.split("", trim: true)
    bid = as_integer(bid)

    %Hand{cards: cards, bid: bid}
  end

  defp as_integer(value) do
    {int, _} = Integer.parse(value)
    int
  end

  @types_weight [
    :five_of_a_kind,
    :four_of_a_kind,
    :full_house,
    :three_of_a_kind,
    :two_pair,
    :one_pair,
    :high_card
  ]
  |> Enum.reverse()
  |> Enum.with_index()
  |> Enum.reverse()
  |> Map.new()

  def sort_hands_by_type(hands, opts \\ []) do
    hands
    |> Enum.map(fn hand ->
      type = hand_type(hand, opts)
      {hand, type}
    end)
    |> Enum.sort(&compare_hands_by_type(&1, &2, opts))
    |> Enum.map(fn {hand, _type} -> hand end)
  end

  defp compare_hands_by_type({hand_1, type_1}, {hand_2, type_2}, opts) do
    hand_weight_1 = @types_weight[type_1]
    hand_weight_2 = @types_weight[type_2]

    if hand_weight_1 == hand_weight_2,
      do: compare_cards_by_label(hand_1.cards, hand_2.cards, opts),
      else: hand_weight_1 < hand_weight_2
  end

  defp compare_cards_by_label(cards_1, cards_2, opts) do
    Stream.zip(cards_1, cards_2)
    |> Stream.map(fn {card_1, card_2} ->
      {card_weight(card_1, opts), card_weight(card_2, opts)}
    end)
    |> Enum.reduce_while(false, fn
      {w, w}, _ -> {:cont, false}
      {cw1, cw2}, _ -> {:halt, cw1 > cw2}
    end)
  end

  defp hand_type(%Hand{cards: cards}, opts) do
    jokers =
      if Keyword.get(opts, :use_jokers, false),
        do: :with_jokers,
        else: :without_jokers

    cond do
      five_of_a_kind?(cards, jokers) -> :five_of_a_kind
      four_of_a_kind?(cards, jokers) -> :four_of_a_kind
      full_house?(cards, jokers) -> :full_house
      three_of_a_kind?(cards, jokers) -> :three_of_a_kind
      two_pair?(cards, jokers) -> :two_pair
      one_pair?(cards, jokers) -> :one_pair
      true -> :high_card
    end
  end

  defp five_of_a_kind?(cards, :without_jokers) do
    first_card = Enum.at(cards, 0)
    Enum.all?(cards, & &1 == first_card)
  end

  defp five_of_a_kind?(cards, :with_jokers) do
    cards
    |> Enum.group_by(& &1)
    |> Map.drop(["J"])
    |> (fn rem_groups ->
      map_size(rem_groups) in [0, 1]
    end).()
  end

  def four_of_a_kind?(cards, use_jokers),
    do: greatest_group(cards, use_jokers) == 4

  defp full_house?(cards, :without_jokers) do
    cards
    |> Enum.group_by(& &1)
    |> Enum.map(fn {_card, occ} -> length(occ) end)
    |> case do
      [2, 3] -> true
      [3, 2] -> true
      _ -> false
    end
  end

  defp full_house?(cards, :with_jokers) do
    joker_count = Enum.count(cards, & &1 == "J")

    cards
    |> Enum.reject(& &1 == "J")
    |> Enum.group_by(& &1)
    |> Enum.map(fn {_, a} -> length(a) end)
    |> case do
      [2, 2] -> joker_count == 1
      [3, 2] -> true
      [2, 3] -> true
      _ -> false
    end
  end

  defp three_of_a_kind?(cards, use_jokers),
    do: greatest_group(cards, use_jokers) == 3

  defp greatest_group(cards, :without_jokers) do
    cards
    |> Enum.group_by(& &1)
    |> Enum.map(fn {_card, occ} -> length(occ) end)
    |> Enum.max()
  end

  defp greatest_group(cards, :with_jokers) do
    groups =
      cards
      |> Enum.group_by(& &1)
      |> Enum.map(fn {card, occ} -> {card, length(occ)} end)
      |> Map.new()

    joker_count = Map.get(groups, "J", 0)

    groups
    |> Map.drop(["J"])
    |> Enum.map(fn {_, label_count} ->
      label_count + joker_count
    end)
    |> Enum.max()
  end

  defp two_pair?(cards, use_jokers),
    do: count_pairs(cards, use_jokers) == 2

  defp one_pair?(cards, use_jokers),
    do: count_pairs(cards, use_jokers) == 1

  defp count_pairs(cards, :without_jokers) do
    cards
    |> Enum.group_by(& &1)
    |> Enum.count(fn {_, occ} -> length(occ) == 2 end)
  end

  defp count_pairs(cards, :with_jokers) do
    joker_count = Enum.count(cards, & &1 == "J")

    pairs_count =
      cards
      |> Enum.group_by(& &1)
      |> Enum.count(fn {_, cards} -> length(cards) == 2 end)

    max(joker_count, pairs_count)
  end

  @cards_weight_without_jokers ~w(A K Q J T 9 8 7 6 5 4 3 2)
               |> Enum.with_index()
               |> Map.new()

  @cards_weight_with_jokers ~w(A K Q T 9 8 7 6 5 4 3 2 J)
               |> Enum.with_index()
               |> Map.new()

  defp card_weight(card, opts) do
    use_jokers = Keyword.get(opts, :use_jokers, false)

    if use_jokers,
      do: @cards_weight_with_jokers[card],
      else: @cards_weight_without_jokers[card]
  end

end

defmodule Aoc2023.Day7.Part1 do
  import Aoc2023.Day7

  def run(input) do
    input
    |> parse_input()
    |> sort_hands_by_type(use_jokers: false)
    |> Enum.map(& &1.bid)
    |> Enum.with_index(1)
    |> Enum.map(fn {bid, rank} -> bid * rank end)
    |> Enum.sum()
  end

end

defmodule Aoc2023.Day7.Part2 do
  import Aoc2023.Day7

  def run(input) do
    input
    |> parse_input()
    |> sort_hands_by_type(use_jokers: true)
    |> Enum.map(& &1.bid)
    |> Enum.with_index(1)
    |> Enum.map(fn {bid, rank} -> bid * rank end)
    |> Enum.sum()
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day7.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day7.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

