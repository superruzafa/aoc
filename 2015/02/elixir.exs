defmodule Aoc2015.Day2.Dimensions do
  defstruct [
    width: 0,
    height: 0,
    length: 0
  ]

  def parse(dimensions) do
    [width, height, length] = String.split(dimensions, "x", trim: true)
    %__MODULE__{
      width: as_integer(width),
      height: as_integer(height),
      length: as_integer(length),
    }
  end

  defp as_integer(string) do
    {int, _} = Integer.parse(string)
    int
  end
end

defmodule Aoc2015.Day2.Part1 do

  alias Aoc2015.Day2.Dimensions

  def run(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&Dimensions.parse/1)
    |> Enum.map(&calculate_surfaces/1)
    |> Enum.sum()
  end

  defp calculate_surfaces(%Dimensions{} = dimensions) do
    surfaces = [
      dimensions.width * dimensions.height,
      dimensions.width * dimensions.length,
      dimensions.height * dimensions.length
    ]

    min_surface = Enum.min(surfaces)

    double_surfaces =
      surfaces
      |> Enum.map(& &1 * 2)
      |> Enum.sum()

    double_surfaces + min_surface
  end

end

defmodule Aoc2015.Day2.Part2 do

  alias Aoc2015.Day2.Dimensions

  def run(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&Dimensions.parse/1)
    |> Enum.map(&needed_ribbon_length/1)
    |> Enum.sum()
  end

  defp needed_ribbon_length(%Dimensions{} = dim) do
    [min_dim_1, min_dim_2] =
      [dim.width, dim.height, dim.length]
      |> Enum.sort()
      |> Enum.take(2)

    ribbon_length = min_dim_1 * 2 + min_dim_2 * 2
    bow_length = dim.width * dim.height * dim.length

    ribbon_length + bow_length
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day2.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day2.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

