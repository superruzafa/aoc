#!/bin/env elixir

defmodule Aoc2025.Day07.Shared do
  def parse_input(input) do
    map =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> parse_lines()

    {width, height} =
      Enum.reduce(map, {0, 0}, fn {{x, y}, _cell}, {w, h} ->
        {max(x, w), max(y, h)}
      end)

    xy0 = map |> find_start() |> down()

    {
      map,
      {width + 1, height + 1},
      xy0
    }
  end

  defp parse_lines(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} -> parse_line(line, y) end)
    |> Map.new()
  end

  defp parse_line(line, y) do
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
  end

  defp find_start(map) do
    Enum.find_value(map, fn
      {xy, "S"} -> xy
      _ -> false
    end)
  end

  def left({x, y}), do: {x - 1, y}

  def right({x, y}), do: {x + 1, y}

  def down({x, y}), do: {x, y + 1}
end

defmodule Aoc2025.Day07.Cache do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_lazy(key, fun) do
    case Agent.get(__MODULE__, &Map.get(&1, key)) do
      nil ->
        value = fun.()
        Agent.update(__MODULE__, &Map.put(&1, key, value))
        value

      value ->
        value
    end
  end
end

defmodule Aoc2025.Day07.Part1 do
  import Aoc2025.Day07.Shared

  def run(input) do
    {map, size, xy0} = parse_input(input)

    MapSet.size(find_splits(map, size, xy0))
  end

  defp find_splits(map, size, xy, splits \\ MapSet.new())

  defp find_splits(_map, _size, {-1, _y}, splits), do: splits

  defp find_splits(_map, {width, _height}, {width, _y}, splits), do: splits

  defp find_splits(_map, {_width, height}, {_x, height}, splits), do: splits

  defp find_splits(map, size, xy, splits) do
    if MapSet.member?(splits, xy) do
      splits
    else
      case Map.get(map, xy) do
        "." ->
          find_splits(map, size, down(xy), splits)

        "^" ->
          splits
          |> MapSet.put(xy)
          |> then(&find_splits(map, size, left(xy), &1))
          |> then(&find_splits(map, size, right(xy), &1))
      end
    end
  end
end

defmodule Aoc2025.Day07.Part2 do
  import Aoc2025.Day07.Shared

  alias Aoc2025.Day07.Cache

  def run(input) do
    Cache.start_link()
    {map, size, xy0} = parse_input(input)
    1 + count_timelines(map, size, xy0)
  end

  defp count_timelines(_map, _size, {-1, _y}), do: 0

  defp count_timelines(_map, {width, _height}, {width, _y}), do: 0

  defp count_timelines(_map, {_width, height}, {_x, height}), do: 0

  defp count_timelines(map, size, xy) do
    case Map.get(map, xy) do
      "." ->
        count_timelines(map, size, down(xy))

      "^" ->
        left_timelines =
          Cache.get_lazy(
            left(xy),
            fn -> count_timelines(map, size, left(xy)) end
          )

        right_timelines =
          Cache.get_lazy(
            right(xy),
            fn -> count_timelines(map, size, right(xy)) end
          )

        1 + left_timelines + right_timelines
    end
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day07.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day07.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end
