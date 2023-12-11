defmodule Aoc2023.Day11.Universe do
   defstruct [
    galaxies: MapSet.new(),
    width: 0,
    height: 0,
    expansion_size: 2
   ]

  def parse(input) do
    rows =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    width = rows |> hd() |> String.length()
    height = length(rows)

    galaxies =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.filter(fn {e, _x} -> e == "#" end)
        |> Enum.map(fn {_, x} -> {x, y} end)
      end)
      |> MapSet.new()

    %__MODULE__{
      galaxies: galaxies,
      width: width,
      height: height
    }

  end

  def galaxies(%__MODULE__{galaxies: galaxies}),
    do: MapSet.to_list(galaxies)

  def expand(%__MODULE__{} = universe, size \\ 2) do
    universe
    |> Map.put(:expansion_size, size)
    |> expand_horizontally(0)
    |> expand_vertically(0)
  end

  defp expand_horizontally(%{width: width} = universe, width),
    do: universe

  defp expand_horizontally(universe, col) do
    {universe, delta} =
      if empty_col?(universe, col),
        do: {expand_col(universe, col), universe.expansion_size},
        else: {universe, 1}

    expand_horizontally(universe, col + delta)
  end

  defp expand_vertically(%{height: height} = universe, height),
    do: universe

  defp expand_vertically(universe, y) do
    {universe, delta} =
      if empty_row?(universe, y),
        do: {expand_row(universe, y), universe.expansion_size},
        else: {universe, 1}

    expand_vertically(universe, y + delta)
  end

  defp empty_row?(universe, y) do
    universe
    |> galaxies()
    |> Enum.all?(fn
      {_, ^y} -> false
      _ -> true
    end)
  end

  def empty_col?(universe, x) do
    universe
    |> galaxies()
    |> Enum.all?(fn
      {^x, _} -> false
      _ -> true
    end)
  end

  defp expand_col(universe, col) do
    galaxies =
      universe
      |> galaxies()
      |> Enum.map(fn
        {x, y} when col < x -> {x + universe.expansion_size - 1, y}
        xy -> xy
      end)
      |> MapSet.new()

    %{universe |
      galaxies: galaxies,
      width: universe.width + universe.expansion_size - 1
    }
  end

  def expand_row(universe, row) do
    galaxies =
      universe
      |> galaxies()
      |> Enum.map(fn
        {x, y} when row < y -> {x, y + universe.expansion_size - 1}
        xy -> xy
      end)
      |> MapSet.new()

    %{universe |
      galaxies: galaxies,
      height: universe.height + universe.expansion_size - 1
    }
  end

  def draw(%__MODULE__{} = universe) do
    for y <- 0..universe.height - 1 do
      for x <- 0..universe.width - 1 do
        if Map.has_key?(universe.galaxies, {x, y}),
          do: IO.write("#"),
          else: IO.write(".")
      end
      IO.puts("")
    end

    universe
  end

end

defmodule Aoc2023.Day11 do
  alias Aoc2023.Day11.Universe

  def sum_all_shortest_paths(%Universe{} = universe) do
    universe
    |> Universe.galaxies()
    |> do_sum_shortest_paths()
  end

  defp do_sum_shortest_paths(galaxies, sum \\ 0)

  defp do_sum_shortest_paths([], sum), do: sum

  defp do_sum_shortest_paths([galaxy_a | rest], sum) do
    sum = Enum.reduce(rest, sum, fn galaxy_b, partial_sum ->
      partial_sum + shortest_path_length(galaxy_a, galaxy_b)
    end)

    do_sum_shortest_paths(rest, sum)
  end

  defp shortest_path_length({x0, y0}, {x1, y1}),
    do: abs(y1 - y0) + abs(x1 - x0)
end

defmodule Aoc2023.Day11.Part1 do
  alias Aoc2023.Day11.Universe

  import Aoc2023.Day11

  def run(input) do
    input
    |> Universe.parse()
    |> Universe.expand(2)
    |> sum_all_shortest_paths()
  end

end

defmodule Aoc2023.Day11.Part2 do
  alias Aoc2023.Day11.Universe

  import Aoc2023.Day11

  def run(input) do
    input
    |> Universe.parse()
    |> Universe.expand(1_000_000)
    |> sum_all_shortest_paths()
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day11.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day11.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

