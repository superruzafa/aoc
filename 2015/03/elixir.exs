defmodule Aoc2015.Day3 do
  def move({x, y}, ?>), do: {x + 1, y}
  def move({x, y}, ?<), do: {x - 1, y}
  def move({x, y}, ?^), do: {x, y + 1}
  def move({x, y}, ?v), do: {x, y - 1}

  def visit(houses, point) do
    MapSet.put(houses, point)
  end
end

defmodule Aoc2015.Day3.Part1 do
  alias Aoc2015.Day3

  def run(input) do
    point = {0, 0}
    houses = Day3.visit(MapSet.new(), point)

    {houses, _point} =
      input
      |> File.read!()
      |> String.trim()
      |> String.to_charlist()
      |> Enum.reduce({houses, point}, fn movement, {houses, point} ->
        point = Day3.move(point, movement)
        houses = Day3.visit(houses, point)
        {houses, point}
      end)

    MapSet.size(houses)
  end

end

defmodule Aoc2015.Day3.Part2 do

  alias Aoc2015.Day3

  @santas 2

  def run(input) do
    points = for i <- 1..@santas, do: {0, 0}

    houses = 
      points
      |> Enum.reduce(MapSet.new(), fn point, houses ->
        Day3.visit(houses, point)
      end)

    {houses, _points} =
      input
      |> File.read!()
      |> String.trim()
      |> String.to_charlist()
      |> Enum.chunk_every(@santas)
      |> Enum.reduce({houses, points}, fn movements, {houses, points} ->
        points =
          movements
          |> Enum.zip(points)
          |> Enum.map(fn {movement, point} -> Day3.move(point, movement) end)

        houses =
          points
          |> Enum.reduce(houses, fn point, houses ->
            Day3.visit(houses, point)
          end)

        {houses, points}

      end)

    MapSet.size(houses)
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day3.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day3.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

