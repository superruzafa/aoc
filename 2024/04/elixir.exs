#!/bin/env elixir

defmodule Aoc2024.Day4.Shared do
  def parse_input(input) do
    {coords, _} =
      input
      |> File.read!()
      |> String.split("", trim: true)
      |> Enum.map_reduce({0, 0}, fn
        "\n", {_, y} -> {nil, {0, y + 1}}
        char, {x, y} -> {{{x, y}, char}, {x + 1, y}}
      end)

    map =
      coords
      |> Enum.reject(&is_nil/1)
      |> Map.new()

    {width, height} =
      map
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn {x, y}, {xmax, ymax} -> {max(x, xmax), max(y, ymax)} end)

    %{
      map: map,
      size: {width + 1, height + 1}
    }
  end
end

defmodule Aoc2024.Day4.Part1 do
  import Aoc2024.Day4.Shared, only: [parse_input: 1]

  @dirs [
    :north,
    :northeast,
    :east,
    :southeast,
    :south,
    :southwest,
    :west,
    :northwest
  ]

  def run(input) do
    %{map: map, size: {width, height}} =
      parse_input(input)

    coords =
      for x <- 0..width - 1,
          y <- 0..height - 1,
          dir <- @dirs do
      generate_coords({x, y}, dir)
    end

    coords
    |> Enum.map(fn xys ->
      Enum.map_join(xys, &Map.get(map, &1, "."))
    end)
    |> Enum.count(& &1 == "XMAS")
  end


  defp generate_coords(xy, :north), do: gen(xy, {0, -1})
  defp generate_coords(xy, :northeast), do: gen(xy, {1, -1})
  defp generate_coords(xy, :east), do: gen(xy, {1, 0})
  defp generate_coords(xy, :southeast), do: gen(xy, {1, 1})
  defp generate_coords(xy, :south), do: gen(xy, {0, 1})
  defp generate_coords(xy, :southwest), do: gen(xy, {-1, 1})
  defp generate_coords(xy, :west), do: gen(xy, {-1, 0})
  defp generate_coords(xy, :northwest), do: gen(xy, {-1, -1})

  defp gen({x, y}, {dx, dy}) do
    [
      {x + 0 * dx, y + 0 * dy},
      {x + 1 * dx, y + 1 * dy},
      {x + 2 * dx, y + 2 * dy},
      {x + 3 * dx, y + 3 * dy}
    ]
  end
end

defmodule Aoc2024.Day4.Part2 do
  import Aoc2024.Day4.Shared, only: [parse_input: 1]

  @dirs [
    [:se, :ne],
    [:se, :sw],
    [:nw, :ne],
    [:nw, :sw]
  ]

  def run(input) do
    %{
      size: {width, height},
      map: map
    } = parse_input(input)

    coords =
      for y <- 0..(height - 1),
          x <- 0..(width - 1),
          dir <- @dirs do

        xmas_coords({x, y}, dir)
      end

    coords
    |> Enum.map(&xmas_mapper(map, &1))
    |> Enum.count(fn
      ["MAS", "MAS"] -> true
      _otherwise -> false
    end)
  end

  defp xmas_coords(xy, [dir1, dir2]) do
    [
      dir2coords(xy, dir1),
      dir2coords(xy, dir2)
    ]
  end

  defp dir2coords({x, y}, :se), do: [{x - 1, y - 1}, {x, y}, {x + 1, y + 1}]
  defp dir2coords({x, y}, :sw), do: [{x + 1, y - 1}, {x, y}, {x - 1, y + 1}]
  defp dir2coords({x, y}, :ne), do: [{x - 1, y + 1}, {x, y}, {x + 1, y - 1}]
  defp dir2coords({x, y}, :nw), do: [{x + 1, y + 1}, {x, y}, {x - 1, y - 1}]

  defp xmas_mapper(map, [coords1, coords2]) do
    [
      mapper(map, coords1),
      mapper(map, coords2)
    ]
  end

  defp mapper(map, coords) do
    Enum.map_join(coords, fn xy -> Map.get(map, xy, "-") end)
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2024.Day4.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2024.Day4.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

