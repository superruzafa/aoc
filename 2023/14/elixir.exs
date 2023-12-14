defmodule Aoc2023.Day14.Rocks do
  defstruct [
    rounded_rocks: MapSet.new(),
    cubic_rocks: MapSet.new(),
    width: 0,
    height: 0,
    coords: %{}
  ]

  def parse_input(input) do
    rocks =
      input
      |> File.read!()
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)

    rocks =
      rocks
      |> Enum.reduce(%__MODULE__{}, fn
        {{x, y} = xy, "O"}, rocks ->
          %{rocks |
            width: max(rocks.width, x + 1),
            height: max(rocks.height, y + 1),
            rounded_rocks: MapSet.put(rocks.rounded_rocks, xy)
          }
        {{x, y} = xy, "#"}, rocks ->
          %{rocks |
            width: max(rocks.width, x + 1),
            height: max(rocks.height, y + 1),
            cubic_rocks: MapSet.put(rocks.cubic_rocks, xy)
          }
      end)

    coords =
      [:north, :south, :west, :east]
      |> Enum.map(fn direction -> {direction, coords(rocks, direction)} end)
      |> Map.new()

    %{rocks | coords: coords}
  end

  defp parse_line({line, y}) do
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reject(fn {v, _} -> v == "." end)
    |> Enum.map(fn {v, x} -> {{x, y}, v} end)
  end

  defp coords(%__MODULE__{} = rocks, :north) do
    for y <- 0..rocks.height - 1,
      x <- 0..rocks.width - 1 do
      {x, y}
    end
  end

  defp coords(%__MODULE__{} = rocks, :west) do
    for x <- 0..rocks.width - 1,
        y <- 0..rocks.height - 1 do
      {x, y}
    end
  end

  defp coords(%__MODULE__{} = rocks, :south) do
    for y <- rocks.height - 1..0,
        x <- 0..rocks.width - 1 do
      {x, y}
    end
  end

  defp coords(%__MODULE__{} = rocks, :east) do
    for x <- rocks.width-1..0,
        y <- 0..rocks.height - 1 do
      {x, y}
    end
  end

  def roll(rocks, direction) do
    rocks.coords[direction]
    |> Enum.reduce(rocks, fn xy, rocks ->
      rounded_rocks =
        if MapSet.member?(rocks.rounded_rocks, xy) do
          rocks.rounded_rocks
          |> MapSet.delete(xy)
          |> MapSet.put(move(rocks, direction, xy))
        else
          rocks.rounded_rocks
        end

      %{rocks | rounded_rocks: rounded_rocks}
    end)
  end

  defp move(_rocks, :north, {_x, 0} = xy), do: xy

  defp move(rocks, :north, {x, y} = xy) do
    cond do
      MapSet.member?(rocks.rounded_rocks, {x, y - 1}) -> xy
      MapSet.member?(rocks.cubic_rocks, {x, y - 1}) -> xy
      true -> move(rocks, :north, {x, y - 1})
    end
  end

  defp move(rocks, :south, {_x, y} = xy) when y == rocks.height - 1, do: xy

  defp move(rocks, :south, {x, y} = xy) do
    cond do
      MapSet.member?(rocks.rounded_rocks, {x, y + 1}) -> xy
      MapSet.member?(rocks.cubic_rocks, {x, y + 1}) -> xy
      true -> move(rocks, :south, {x, y + 1})
    end
  end

  defp move(_rocks, :west, {0, _y} = xy), do: xy

  defp move(rocks, :west, {x, y} = xy) do
    cond do
      MapSet.member?(rocks.rounded_rocks, {x - 1, y}) -> xy
      MapSet.member?(rocks.cubic_rocks, {x - 1, y}) -> xy
      true -> move(rocks, :west, {x - 1, y})
    end
  end

  defp move(rocks, :east, {x, _y} = xy) when x == rocks.width - 1, do: xy

  defp move(rocks, :east, {x, y} = xy) do
    cond do
      MapSet.member?(rocks.rounded_rocks, {x + 1, y}) -> xy
      MapSet.member?(rocks.cubic_rocks, {x + 1, y}) -> xy
      true -> move(rocks, :east, {x + 1, y})
    end
  end

  def at(%__MODULE__{} = rocks, xy) do
    cond do
      MapSet.member?(rocks.rounded_rocks, xy) -> "O"
      MapSet.member?(rocks.cubic_rocks, xy) -> "#"
      true -> "."
    end
  end

  def calculate(%__MODULE__{} = rocks) do
    rocks.rounded_rocks
    |> Enum.map(fn {_, y} -> rocks.height - y end)
    |> Enum.sum()
  end

end

defimpl Inspect, for: Aoc2023.Day14.Rocks do
  alias Aoc2023.Day14.Rocks

  def inspect(rocks, _opts) do
    rows =
      0..rocks.height - 1
      |> Enum.map(fn y ->
        0..rocks.width - 1
        |> Enum.map(fn x -> Rocks.at(rocks, {x, y}) end)
        |> Enum.join()
      end)

    (rows ++ [""])
    |> Enum.join("\n")
  end
end

defmodule Aoc2023.Day14.Part1 do
  import Aoc2023.Day14.Rocks

  def run(input) do
    input
    |> parse_input()
    |> roll(:north)
    |> calculate()
  end

end

defmodule Aoc2023.Day14.Part2 do
  alias Aoc2023.Day14.Rocks

  import Rocks

  def run(input) do
    solutions =
      input
      |> parse_input()
      |> cycle(200, [])

    {start, length} = find_pattern(solutions, 0)
    pattern = solutions |> Enum.drop(start) |> Enum.take(length)
    iterations = 1_000_000_000 - start - 1
    Enum.at(pattern, rem(iterations, length))
  end

  defp cycle(_rocks, 0, solutions) do
    Enum.reverse(solutions)
  end

  defp cycle(%Rocks{} = rocks, count, solutions) do
    rocks = cycle_one(rocks)
    cycle(rocks, count - 1, [calculate(rocks) | solutions])
  end

  defp cycle_one(%Rocks{} = rocks) do
    rocks
    |> roll(:north)
    |> roll(:west)
    |> roll(:south)
    |> roll(:east)
  end

  @detection_size 50

  defp find_pattern(solutions, start) do
    1..100
    |> Enum.find(fn length ->
      pattern1 = Enum.take(solutions, @detection_size)
      pattern2 = solutions |> Enum.drop(length) |> Enum.take(@detection_size)
      pattern1 == pattern2
    end)
    |> case do
      nil -> find_pattern(Enum.drop(solutions, 1), start + 1)
      length -> {start, length}
    end

  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day14.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day14.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

