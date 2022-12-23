#!/usr/bin/env elixir

defmodule Aoc2022.Day23 do

  @directions ~w(north south west east)a

  def part1 do
    map = load()
    directions_stream =
      @directions
      |> Stream.cycle()
      |> Stream.chunk_every(length(@directions), 1)
    acc = {map, directions_stream}

    {map, _} =
      1..10
      |> Enum.reduce(acc, fn _round, {map, ds} ->
        directions = Enum.take(ds, 1) |> hd()
        {map, _elves_moving} = run(map, directions)
        ds = Stream.drop(ds, 1)
        {map, ds}
      end)

    count_empty_spaces(map)
  end

  def part2 do
    map = load()
    directions_stream =
      @directions
      |> Stream.cycle()
      |> Stream.chunk_every(length(@directions), 1)
    acc = {map, 0, directions_stream}

    Stream.repeatedly(fn -> nil end)
    |> Enum.reduce_while(acc, fn _, {map, round, ds} ->
      directions = Enum.take(ds, 1) |> hd()
      {map, elves_moving} = run(map, directions)
      ds = Stream.drop(ds, 1)

      if elves_moving == 0 do
        {:halt, round + 1}
      else
        {:cont, {map, round + 1, ds}}
      end
    end)
  end

  defp count_empty_spaces(map) do
    {min_x, max_x} =
      map
      |> Enum.map(fn {x, _} -> x end)
      |> Enum.min_max()

    {min_y, max_y} =
      map
      |> Enum.map(fn {_, y} -> y end)
      |> Enum.min_max()

    for x <- min_x..max_x, y <- min_y..max_y do
      {x, y}
    end
    |> Enum.count(&not MapSet.member?(map, &1))
  end

  defp run(map, directions) do
    proposed_positions = 
      Enum.reduce(map, %{}, fn elf_xy, proposed_positions ->
        if someone_around?(map, elf_xy) do
          case propose_position(map, elf_xy, directions) do
            nil -> proposed_positions
            xy -> Map.update(proposed_positions, xy, [elf_xy], &[elf_xy | &1])
          end
        else
          proposed_positions
        end
      end)

    map = 
      proposed_positions
      |> Enum.reduce(map, fn
        {new_elf_xy, [old_elf_xy]}, map ->
          map
          |> MapSet.delete(old_elf_xy)
          |> MapSet.put(new_elf_xy)

        _, map -> 
          map
      end)

    {map, map_size(proposed_positions)}
  end

  defp propose_position(map, elf_xy, directions) do
    directions
    |> Enum.find(&empty?(map, elf_xy, &1))
    |> case do
      nil -> nil
      direction -> step_one(elf_xy, direction)
    end
  end

  defp step_one({x, y}, :north), do: {x, y - 1}
  defp step_one({x, y}, :south), do: {x, y + 1}
  defp step_one({x, y}, :west), do: {x - 1, y}
  defp step_one({x, y}, :east), do: {x + 1, y}

  defp someone_around?(map, {x, y}) do
    xys = 
      for xa <- -1..1,
        ya <- -1..1,
        {xa, ya} != {0, 0},
        into: MapSet.new() do
          {x + xa, y + ya}
      end

    map
    |> MapSet.intersection(xys)
    |> MapSet.size() != 0
  end

  defp empty?(map, xy, direction) when direction in [:north, :south] do
    xy1 = step_one(xy, direction)
    xy2 = step_one(xy1, :west)
    xy3 = step_one(xy1, :east)
    [xy1, xy2, xy3]
    |> Enum.all?(& not MapSet.member?(map, &1))
  end

  defp empty?(map, xy, direction) when direction in [:west, :east] do
    xy1 = step_one(xy, direction)
    xy2 = step_one(xy1, :north)
    xy3 = step_one(xy1, :south)
    [xy1, xy2, xy3]
    |> Enum.all?(& not MapSet.member?(map, &1))
  end

  def load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {"#", x} -> [{x, y}]
        _ -> []
      end)
    end)
    |> MapSet.new()

  end

end

IO.puts("# empty ground tiles at round 10 (part 1): #{Aoc2022.Day23.part1()}")
IO.puts("first round where no elf moved (part 2): #{Aoc2022.Day23.part2()}")

