#!/bin/env elixir

defmodule Aoc2025.Day09.Rect do
  defstruct [:xy0, :xy1]

  def new(xy0, xy1) do
    %__MODULE__{
      xy0: xy0,
      xy1: xy1
    }
  end

  def shrink(%__MODULE__{xy0: {x0, y0}, xy1: {x1, y1}}) do
    __MODULE__.new({x0 + 1, y0 + 1}, {x1 - 1, y1 - 1})
  end

  def normalize(%__MODULE__{xy0: {x0, y0}, xy1: {x1, y1}}) do
    __MODULE__.new(
      {min(x0, x1), min(y0, y1)},
      {max(x0, x1), max(y0, y1)}
    )
  end

  def area(%__MODULE__{xy0: {x0, y0}, xy1: {x1, y1}}) do
    (abs(x1 - x0) + 1) * (abs(y1 - y0) + 1)
  end

  def contains?(%__MODULE__{xy0: {x0, y0}, xy1: {x1, y1}}, {x, y}) do
    x0 <= x and x <= x1 and y0 <= y and y <= y1
  end
end

defmodule Aoc2025.Day09.Shared do
  alias Aoc2025.Day09.Rect

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split(",", trim: true)
    |> Enum.map(&parse_integer/1)
    |> List.to_tuple()
  end

  defp parse_integer(value) do
    {n, _} = Integer.parse(value)
    n
  end

  def build_rects([]), do: []

  def build_rects([xy0 | coords]) do
    Enum.map(coords, &Rect.new(xy0, &1)) ++ build_rects(coords)
  end
end

defmodule Aoc2025.Day09.Part1 do
  import Aoc2025.Day09.Shared

  alias Aoc2025.Day09.Rect

  def run(input) do
    input
    |> parse_input()
    |> build_rects()
    |> Enum.reduce(0, &max(Rect.area(&1), &2))
  end
end

defmodule Aoc2025.Day09.Part2 do
  import Aoc2025.Day09.Shared

  alias Aoc2025.Day09.Rect

  def run(input) do
    coords = parse_input(input)
    perimeter = build_perimeter(coords)

    rects =
      coords
      |> build_rects()
      |> Enum.filter(&(4 <= Rect.area(&1)))

    rects
    |> Enum.map(&Rect.normalize/1)
    |> Enum.sort_by(&Rect.area/1, :desc)
    |> Enum.with_index(1)
    |> Task.async_stream(fn {rect, i} ->
      IO.write("\r\e[2K#{i}/#{length(rects)}...")
      if rect_inside_perimeter?(rect, perimeter), do: rect, else: false
    end)
    |> Enum.find_value(fn {:ok, res} -> res end)
    |> tap(fn _ -> IO.write("\r\e[2K") end)
    |> then(&Rect.area/1)
  end

  defp rect_inside_perimeter?(rect, perimeter) do
    not Enum.any?(perimeter, fn xy ->
      rect
      |> Rect.shrink()
      |> Rect.contains?(xy)
    end)
  end

  defp build_perimeter(coords) do
    coords
    |> Kernel.++([hd(coords)])
    |> Enum.chunk_every(2, 1)
    |> Enum.reduce(MapSet.new(), &do_build_perimeter(&2, &1))
  end

  defp do_build_perimeter(perimeter, [{x1, y}, {x2, y}]) do
    min(x1, x2)..max(x1, x2)
    |> Enum.reduce(perimeter, &MapSet.put(&2, {&1, y}))
  end

  defp do_build_perimeter(perimeter, [{x, y1}, {x, y2}]) do
    min(y1, y2)..max(y1, y2)
    |> Enum.reduce(perimeter, &MapSet.put(&2, {x, &1}))
  end

  defp do_build_perimeter(perimeter, [_xy]), do: perimeter
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day09.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day09.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end
