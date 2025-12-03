#!/bin/env elixir

defmodule Aoc2025.Day03.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> parse_lines()
  end

  defp parse_lines(lines) do
    lines
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(&parse_integer/1)
    end)
  end

  defp parse_integer(value) do
    {n, _} = Integer.parse(value)
    n
  end
end

defmodule Aoc2025.Day03.Part1 do
  import Aoc2025.Day03.Shared,
    only: [parse_input: 1]

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&max_subsequence/1)
    |> Enum.sum()
  end

  defp max_subsequence(bank, maximum \\ 0)

  defp max_subsequence([], maximum), do: maximum

  defp max_subsequence([_battery], maximum), do: maximum

  defp max_subsequence([battery | rest], maximum) do
    current = battery * 10 + Enum.max(rest)
    max_subsequence(rest, max(current, maximum))
  end
end

defmodule Aoc2025.Day03.Cache do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_lazy(key, fun) do
    value = Agent.get(__MODULE__, &Map.get(&1, key))

    if is_nil(value) do
      value = fun.()
      Agent.update(__MODULE__, &Map.put(&1, key, value))
      value
    else
      value
    end
  end
end

defmodule Aoc2025.Day03.Part2 do
  import Aoc2025.Day03.Shared,
    only: [parse_input: 1]

  alias Aoc2025.Day03.Cache

  def run(input) do
    Cache.start_link()

    input
    |> parse_input()
    |> Enum.map(&max_subsequence(&1, 12))
    |> Enum.sum()
  end

  defp max_subsequence(bank, n) when length(bank) < n,
    do: 0

  defp max_subsequence(bank, n) when length(bank) == n,
    do: Integer.undigits(bank)

  defp max_subsequence(_, 0), do: 0

  defp max_subsequence([battery | rest], n) do
    max1 = Cache.get_lazy({rest, n - 1}, fn -> max_subsequence(rest, n - 1) end)
    max1 = battery * Integer.pow(10, n - 1) + max1

    max2 = Cache.get_lazy({rest, n}, fn -> max_subsequence(rest, n) end)

    max(max1, max2)
  end
end


case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day03.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day03.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

