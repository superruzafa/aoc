#!/bin/env elixir

defmodule Aoc2025.Day05.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> then(fn [ranges, ingredients] ->
      {
        parse_ranges(ranges),
        parse_ingredients(ingredients)
      }
    end)
  end

  defp parse_ranges(ranges) do
    ranges
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_range/1)
  end

  defp parse_range(line) do
    [_, lower, upper] = Regex.run(~r/(\d+)-(\d+)/, line)
    Range.new(parse_integer(lower), parse_integer(upper))
  end

  defp parse_ingredients(ingredients) do
    ingredients
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_integer/1)
  end

  defp parse_integer(value) do
    {n, _} = Integer.parse(value)
    n
  end
end

defmodule Aoc2025.Day05.Part1 do
  import Aoc2025.Day05.Shared,
    only: [parse_input: 1]

  def run(input) do
    {ranges, ingredients} = parse_input(input)

    Enum.count(ingredients, fn ingredient ->
      Enum.any?(ranges, &ingredient in &1)
    end)
  end
end

defmodule Aoc2025.Day05.Part2 do
  import Aoc2025.Day05.Shared,
    only: [parse_input: 1]

  def run(input) do
    {ranges, _ingredients} = parse_input(input)

    ranges
    |> split_ranges()
    |> Enum.sum_by(&Range.size/1)
  end

  defp split_ranges(ranges, acc \\ [])

  defp split_ranges([], acc), do: acc

  defp split_ranges([range | ranges], acc) do
    split_ranges(ranges, acc ++ split_range(range, ranges))
  end

  defp split_range(range, []), do: [range]

  defp split_range(current, [range | ranges]) do
    current
    |> disjoint_range(range)
    |> Enum.reduce([], fn r, acc ->
      acc ++ split_range(r, ranges)
    end)
  end

  defp disjoint_range(l1..u1//1 = range1, l2..u2//1 = range2) do
    cond do
      Range.disjoint?(range1, range2) ->
        [range1]

      l2 <= l1 and u1 <= u2 ->
        []

      l1 <= l2 and u2 <= u1 and (l2 - 1) <= l1 ->
        [u2 + 1..u1]

      l1 <= l2 and u2 <= u1 and (u1 <= u2 + 1) ->
        [l1..l2 - 1]

      l1 <= l2 and u2 <= u1 ->
        [l1..l2 - 1, u2 + 1..u1]

      l1 < l2 ->
        [l1..l2 - 1]

      u2 < u1 ->
        [u2 + 1..u1]
    end
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day05.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day05.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

