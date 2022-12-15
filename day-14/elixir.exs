#!/usr/bin/env elixir
defmodule Aoc2022.Day14 do

  defmodule Cave do
    defstruct [
      min_x: 99999,
      max_x: 0,
      xy: %{},
      abyss: 0,
      with_infinite_floor: false,
      infinite_floor_y: 0,
      sand_count: 0,
      timestamp: 0.0
    ]

    def new(opts \\ []) do
      infinite_floor = Keyword.get(opts, :infinite_floor, false)

      %__MODULE__{
        with_infinite_floor: infinite_floor
      }
    end

    def put(cave, {x, y} = xy, :rock) do
      %{
        cave |
          xy: Map.put(cave.xy, xy, :rock),
          min_x: min(cave.min_x, x),
          max_x: max(cave.max_x, x),
          abyss: max(cave.abyss, y + 1),
          infinite_floor_y: max(cave.infinite_floor_y, y + 2),
      }
    end

    def put(cave, xy, :sand) do
      %{
        cave |
        xy: Map.put(cave.xy, xy, :sand),
        sand_count: cave.sand_count + 1
      }
    end

    def at(cave, {_, y} = xy) do
      if cave.with_infinite_floor and y >= cave.infinite_floor_y do
        :rock
      else
        Map.get(cave.xy, xy, :air)
      end
    end

    def air?(cave, xy), do: Cave.at(cave, xy) == :air

    def sand?(cave, xy), do: Cave.at(cave, xy) == :sand

    def abyss?(cave, {_, y}), do: cave.abyss <= y

  end

  @drop_point {500, 0}

  def part1 do
    load()
    |> drop(@drop_point)
    |> Map.get(:sand_count)
  end

  def part2 do
    load(infinite_floor: true)
    |> drop_part_2(@drop_point)
    |> Map.get(:sand_count)
  end

  defp down({x, y}), do: {x, y + 1}
  defp left_down({x, y}), do: {x - 1, y + 1}
  defp right_down({x, y}), do: {x + 1, y + 1}

  defp drop(cave, xy) do
    xy_down = down(xy)
    xy_left_down = left_down(xy)
    xy_right_down = right_down(xy)

    if Cave.abyss?(cave, xy) do
      cave
    else
      {cave, next_xy} =
        cond do
          Cave.air?(cave, xy_down) -> {cave, xy_down}
          Cave.air?(cave, xy_left_down) -> {cave, xy_left_down}
          Cave.air?(cave, xy_right_down) -> {cave, xy_right_down}
          true -> {Cave.put(cave, xy, :sand), @drop_point}
        end

      drop(cave, next_xy)
    end
  end
  
  defp drop_part_2(cave, xy) do
    xy_down = down(xy)
    xy_left_down = left_down(xy)
    xy_right_down = right_down(xy)

    if Cave.sand?(cave, xy) do
      cave
    else
      {cave, next_xy} =
        cond do
          Cave.air?(cave, xy_down) -> {cave, xy_down}
          Cave.air?(cave, xy_left_down) -> {cave, xy_left_down}
          Cave.air?(cave, xy_right_down) -> {cave, xy_right_down}
          true -> 
            {Cave.put(cave, xy, :sand), @drop_point}

        end

      drop_part_2(cave, next_xy)
    end
  end
  
  def load(opts \\ []) do
    lines =
      "./input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)

    Enum.reduce(lines, Cave.new(opts), &parse_line/2)
  end

  defp parse_line(line, cave) do
    xys = line
      |> String.split(" -> ", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> case do [x, y] -> {x, y} end
      end)

    [xy1 | xys] = xys

    acc = {xy1, cave}

    {_, cave} =
      xys
      |> Enum.reduce(acc, fn {x2, y2} = xy2, {{x1, y1}, cave} ->
        rock_coords = for y <- y1..y2, x <- x1..x2, do: {x, y}

        cave = Enum.reduce(rock_coords, cave, fn xy, cave ->
          Cave.put(cave, xy, :rock)
        end)

        {xy2, cave}
      end)

    cave
  end


end

IO.puts("# units of sand come to rest before flowing into abyss (part 1): #{Aoc2022.Day14.part1()}")
IO.puts("# units of sand come to rest before source becomes blocked (part 2): #{Aoc2022.Day14.part2()}")

