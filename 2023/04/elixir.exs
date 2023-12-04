defmodule Aoc2023.Day4.Scratchcard do
  defstruct [
    :id,
    :winning,
    :actual,
    count: 1
  ]

  def parse(line) do
    regex = ~r/Card\s+(?<id>\d+): (?<winning>[^|]+)\|(?<actual>.+)/
    matches = Regex.named_captures(regex, line)
    %__MODULE__{
      id: as_integer(matches["id"]),
      winning: parse_numbers(matches["winning"]),
      actual: parse_numbers(matches["actual"]),
    }
  end

  defp parse_numbers(numbers) do
    numbers
    |> String.split(" ", trim: true)
    |> Enum.map(&as_integer/1)
    |> MapSet.new()
  end

  defp as_integer(number) do
    {int, _} = Integer.parse(number)
    int
  end

end

defmodule Aoc2023.Day4 do
  alias Aoc2023.Day4.Scratchcard

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&Scratchcard.parse/1)
  end

end

defmodule Aoc2023.Day4.Part1 do
  alias Aoc2023.Day4.Scratchcard

  import Aoc2023.Day4

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&count_points/1)
    |> Enum.sum()
  end

  defp count_points(%Scratchcard{} = card) do
    card.actual
    |> Enum.reduce(0, fn number, points ->
      case {points, number in card.winning} do
        {0, true} -> 1
        {points, true} -> points * 2
        {points, false} ->  points
      end
    end)
  end

end

defmodule Aoc2023.Day4.Part2 do
  alias Aoc2023.Day4.Scratchcard

  import Aoc2023.Day4

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(& {&1.id, &1})
    |> Enum.into(%{})
    |> traverse()
  end

  defp traverse(cards, card_id \\ 1)

  defp traverse(cards, card_id) when card_id == map_size(cards) + 1 do
    cards
    |> Enum.map(fn {_, sc} -> sc.count  end)
    |> Enum.sum()
  end

  defp traverse(cards, card_id) do
    matches = count_matching(cards[card_id])

    curr_card = cards[card_id]
    card0_id = (card_id + 1)
    card1_id = min(map_size(cards), card_id + matches)

    cards =
      if card1_id < card0_id do
        cards
      else
        card0_id..card1_id
        |> Enum.reduce(cards, fn cardi_id, cards ->
          card_i = cards[cardi_id] |> Map.update!(:count, & &1  + curr_card.count)
          Map.put(cards, cardi_id, card_i)
        end)
      end

    traverse(cards, card_id + 1)
  end

  defp count_matching(%Scratchcard{} = card) do
    card.actual
    |> MapSet.intersection(card.winning)
    |> MapSet.size()
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day4.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day4.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

