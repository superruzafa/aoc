defmodule Aoc2023.Day21.Garden do
  defstruct [
    start: {0, 0},
    size: {0, 0},
    rocks: MapSet.new(),
    infinite?: false,
  ]

  def parse(input, opts \\ []) do
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
      infinite?: Keyword.get(opts, :infinite?, false),
      size: {width, height},
      rocks: cells |> Map.keys() |> MapSet.new()
    }
  end

  def at(%__MODULE{infinite?: false} = garden, {x, y} = xy) do
    %{size: {width, height}} = garden;
    cond do
      x < 0 or width <= x -> nil
      y < 0 or height <= y -> nil
      xy == garden.start -> :start
      MapSet.member?(garden.rocks, xy) -> :rock
      true -> :plot
    end
  end

  def at(%__MODULE{infinite?: true} = garden, {x, y}) do
    %{size: {width, height}} = garden;
    x = rem_cycle(x, width)
    y = rem_cycle(y, height)
    xy = {x, y}

    cond do
      xy == garden.start -> :start
      MapSet.member?(garden.rocks, xy) -> :rock
      true -> :plot
    end
  end

  defp rem_cycle(a, b) when a >=0, do: rem(a, b)
  defp rem_cycle(a, b), do: b + rem(a + 1, b) - 1

  def plot?(%__MODULE{} = garden,  xy), 
    do: at(garden, xy) in [:plot, :start]

end

defmodule Aoc2023.Day21 do
  alias Aoc2023.Day21.Garden

  def move({x, y}, :north), do: {x, y - 1}
  def move({x, y}, :south), do: {x, y + 1}
  def move({x, y}, :west), do: {x - 1, y}
  def move({x, y}, :east), do: {x + 1, y}

  def draw(%Garden{infinite?: false} = garden, visited) do
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
    garden

  end

  def draw(%Garden{infinite?: true} = garden, visited) do
    %{size: {width, height}} = garden
    {xy_min, xy_max} = boundaries(visited)
    {x_min, y_min} = min_point({0, 0}, xy_min)
    {x_max, y_max} = max_point({width, height - 1}, xy_max)

    for y <- y_min..y_max do
      for x <- x_min..x_max do
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
    garden

  end

  defp boundaries(visited) do
    Enum.reduce(visited, nil, fn
      xy0, nil -> {xy0, xy0}
      xy, {xy_min, xy_max} ->
        xy_min = min_point(xy, xy_min)
        xy_max = max_point(xy, xy_max)
        {xy_min, xy_max}
    end)
  end

  defp min_point({x0, y0}, {x1, y1}) do
    {min(x0, x1), min(y0, y1)}
  end

  defp max_point({x0, y0}, {x1, y1}) do
    {max(x0, x1), max(y0, y1)}
  end


end

defmodule Aoc2023.Day21.Part1 do
  alias Aoc2023.Day21.Garden

  def run(input) do
    garden = input |> Garden.parse(infinite?: true)
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
  def run(_input) do
    ""
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day21.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day21.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

