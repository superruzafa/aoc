defmodule Aoc2023.Day21.Garden do
  defstruct [
    start: {0, 0},
    size: {0, 0},
    rocks: MapSet.new()
  ]

  def parse(input) do
    rows =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    width = String.length(hd(rows))
    height = length(rows)

    cells =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.flat_map(fn
          {".", _x} -> []
          {"S", x} -> [{:start, {x, y}}]
          {v, x} -> [{{x, y}, v}]
        end)
      end)
      |> Map.new()

    {start, cells} = Map.pop!(cells, :start)

    %__MODULE__{
      start: start,
      size: {width, height},
      rocks: cells |> Map.keys() |> MapSet.new()
    }
  end

  def at(%__MODULE{} = garden, {x, y} = xy) do
    %{size: {width, height}} = garden;
    cond do
      x < 0 or width <= x -> nil
      y < 0 or height <= y -> nil
      xy == garden.start -> :start
      MapSet.member?(garden.rocks, xy) -> :rock
      true -> :plot
    end
  end

  def plot?(%__MODULE{} = garden,  xy), 
    do: at(garden, xy) in [:plot, :start]

end

defmodule Aoc2023.Day21 do
  alias Aoc2023.Day21.Garden

  def move({x, y}, :north), do: {x, y - 1}
  def move({x, y}, :south), do: {x, y + 1}
  def move({x, y}, :west), do: {x - 1, y}
  def move({x, y}, :east), do: {x + 1, y}

  def draw(%Garden{} = garden, visited) do
    %{size: {width, height}} = garden
    for y <- 0..height - 1 do
      for x <- 0..width - 1 do
        xy = {x, y}
        garden_at = Garden.at(garden, xy)
        visited_at = MapSet.member?(visited, xy)

        case {garden_at, visited_at} do
          {_, true} -> "O"
          {:plot, _} -> "."
          {:start, _} -> "S"
          {:rock, _} -> "#"
        end
        |> IO.write()
      end
      IO.puts("")
    end
  end
end

defmodule Aoc2023.Day21.Part1 do
  alias Aoc2023.Day21.Garden

  def run(input) do
    garden = input |> Garden.parse()
    cache = %{0 => MapSet.new([garden.start])}

    garden
    |> walk(0, cache)
    |> Enum.filter(fn {step, _visited} -> rem(step, 2) == 0 end)
    |> Enum.map(fn {_step, visited} -> visited end)
    |> Enum.reduce(fn set1, set2 ->
      MapSet.union(set1, set2)
    end)
    |> MapSet.size()
  end

  defp walk(_garden, 64, cache), do: cache

  defp walk(garden, step, cache) do
    next =
      cache
      |> Map.fetch!(step)
      |> Enum.flat_map(&adjacents/1)
      |> Enum.filter(& Garden.plot?(garden, &1))
      |> Enum.reject(& visited?(cache, &1))
      |> MapSet.new()

    cache = Map.put(cache, step + 1, next)
    walk(garden, step + 1, cache)
  end

  defp visited?(cache, xy) do
    cache
    |> Enum.any?(fn {_step, visited} ->
      MapSet.member?(visited, xy)
    end)
  end

  defp adjacents({x, y}) do
    [
      {x, y - 1},
      {x + 1, y},
      {x, y + 1},
      {x - 1, y}
    ]
  end

end

defmodule Aoc2023.Day21.Part2 do
  def run(input) do
    input
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day21.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day21.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

