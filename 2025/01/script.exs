#!/bin/env elixir

defmodule Aoc2025.Day01.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> parse_lines()
  end

  defp parse_lines(lines) do
    lines
    |> Enum.map(fn line ->
      Regex.run(~r/([LR])(\d+)/, line)
    end)
    |> Enum.map(fn [_, direction, distance] ->
      {parse_direction(direction), parse_distance(distance)}
    end)
  end

  defp parse_direction("L"), do: :left
  defp parse_direction("R"), do: :right

  defp parse_distance(distance) do
    {n, _} = Integer.parse(distance)
    n
  end

  def rotate(position, {:left, distance}) do
    rem(rem(position - distance, 100) + 100, 100)
  end

  def rotate(position, {:right, distance}) do
    rem(position + distance, 100)
  end
end

defmodule Aoc2025.Day01.Part1 do
  import Aoc2025.Day01.Shared,
    only: [parse_input: 1, rotate: 2]

  def run(input) do
    {positions, _} =
      input
      |> parse_input()
      |> Enum.map_reduce(50, fn rotation, position ->
        new_position = rotate(position, rotation)
        {new_position, new_position}
      end)

    Enum.count(positions, & &1 == 0)
  end

end

defmodule Aoc2025.Day01.Part2 do
  import Aoc2025.Day01.Shared,
    only: [parse_input: 1, rotate: 2]

  def run(input) do
    input
    |> parse_input()
    |> do_run(50, 0)
  end

  defp do_run([], _position, clicks), do: clicks

  defp do_run([{direction, distance} | rest], position, clicks) when distance >= 100 do
    do_run([{direction, distance - 100} | rest], position, clicks + 1)
  end

  defp do_run([rotation | rest], 0, clicks) do
    new_position = rotate(0, rotation)
    do_run(rest, new_position, clicks)
  end

  defp do_run([{:left, distance} = rotation | rest], position, clicks) when 0 < distance - position do
    new_position = rotate(position, rotation)
    do_run(rest, new_position, clicks + 1)
  end

  defp do_run([{:right, distance} = rotation | rest], position, clicks) when 100 <= position + distance do
    new_position = rotate(position, rotation)
    do_run(rest, new_position, clicks + 1)
  end

  defp do_run([rotation | rest], position, clicks) do
    new_position = rotate(position, rotation)
    clicks = if new_position == 0, do: clicks + 1, else: clicks
    do_run(rest, new_position, clicks)
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day01.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day01.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

