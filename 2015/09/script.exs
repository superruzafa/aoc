#!/bin/env elixir

defmodule Aoc2015.Day08.Shared do
  def parse_input(input) do
    distances =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Map.new(&parse_line/1)

    cities = extract_cities(distances)

    {distances, cities}
  end

  defp parse_line(line) do
    [_, from, to, distance] =
      Regex.run(~r/^(\w+) to (\w+) = (\d+)$/, line)

    {{from, to}, parse_integer(distance)}
  end

  defp parse_integer(value) do
    {n, _} = Integer.parse(value)
    n
  end

  defp extract_cities(distance) do
    distance
    |> Map.keys()
    |> Enum.flat_map(&Tuple.to_list/1)
    |> MapSet.new()
  end

  def cities_distance(distances, city1, city2) do
    dist1 = Map.get(distances, {city1, city2})
    dist2 = Map.get(distances, {city2, city1})

    case {dist1, dist2} do
      {nil, nil} -> raise {city1, city2}
      {dist1, nil} -> dist1
      {nil, dist2} -> dist2
    end
  end
end

defmodule Aoc2015.Day08.Part1 do
  import Aoc2015.Day08.Shared

  def run(input) do
    {distances, cities} =
      input
      |> parse_input()

    cities
    |> Enum.map(&min_distance(distances, cities, &1, 0))
    |> Enum.min()
  end

  defp min_distance(distances, remaining_cities, from_city, distance_acc) do
    if MapSet.size(remaining_cities) == 1 do
      distance_acc
    else
      remaining_cities = MapSet.delete(remaining_cities, from_city)

      remaining_cities
      |> Enum.map(fn to_city ->
        distance_acc = distance_acc + cities_distance(distances, from_city, to_city)
        min_distance(distances, remaining_cities, to_city, distance_acc)
      end)
      |> Enum.min()
    end
  end
end

defmodule Aoc2015.Day08.Part2 do
  import Aoc2015.Day08.Shared

  def run(input) do
    {distances, cities} =
      input
      |> parse_input()

    cities
    |> Enum.map(&max_distance(distances, cities, &1, 0))
    |> Enum.max()
  end

  defp max_distance(distances, remaining_cities, from_city, distance_acc) do
    if MapSet.size(remaining_cities) == 1 do
      distance_acc
    else
      remaining_cities = MapSet.delete(remaining_cities, from_city)

      remaining_cities
      |> Enum.map(fn to_city ->
        distance_acc = distance_acc + cities_distance(distances, from_city, to_city)
        max_distance(distances, remaining_cities, to_city, distance_acc)
      end)
      |> Enum.max()
    end
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day08.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day08.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end
