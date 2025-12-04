#!/bin/env elixir

defmodule Aoc2025.Day04.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> parse_lines()
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

  def rolls_around(map, xy) do
    xy
    |> adjacents()
    |> Enum.count(&Map.get(map, &1, ".") == "@")
  end

  defp adjacents({x, y}) do
    [
      {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
      {x - 1, y},                 {x + 1, y},
      {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
    ]
  end
end

defmodule Aoc2025.Day04.Part1 do
  import Aoc2025.Day04.Shared

  def run(input) do
    map = parse_input(input)

    map
    |> Enum.filter(fn {_xy, cell} -> cell == "@" end)
    |> Enum.map(fn {xy, _cell} -> xy end)
    |> Enum.count(&rolls_around(map, &1) < 4)
  end
end

defmodule Aoc2025.Day04.Part2 do
  import Aoc2025.Day04.Shared

  def run(input) do
    input
    |> parse_input()
    |> do_run()
  end

  defp do_run(map, acc \\ 0)

  defp do_run(map, acc) when map_size(map) == 0, do: acc

  defp do_run(map, acc) do
    map
    |> Enum.filter(fn {_, cell} -> cell == "@" end)
    |> Enum.map(fn {xy, _cell} -> xy end)
    |> Enum.filter(&rolls_around(map, &1) < 4)
    |> case do
      [] ->
        acc
      removables ->
        map
        |> Map.drop(removables)
        |> do_run(acc + length(removables))
    end
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day04.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day04.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

