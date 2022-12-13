#!/usr/bin/env elixir
defmodule Aoc2022.Day12 do

  alias Graph.Pathfinding

  def part1 do
    map = load()
    vertices = Map.keys(map)
    edges = build_edges(map)
    graph = 
      Graph.new()
      |> Graph.add_vertices(vertices)
      |> Graph.add_edges(edges)

    a = Enum.find(map, fn {k, v} -> v == ?S end) |> case do {k, _v} -> k end
    b = Enum.find(map, fn {k, v} -> v == ?E end) |> case do {k, _v} -> k end

    path = Pathfinding.a_star(graph, a, b, fn _ -> 0 end)
    #show(map, path, a)
    length(path) - 1
  end

  def part2 do
    map = load()
    vertices = Map.keys(map)
    edges = build_edges(map)
    graph = 
      Graph.new()
      |> Graph.add_vertices(vertices)
      |> Graph.add_edges(edges)

    a = map
        |> Enum.find(fn {k, v} -> v == ?S end)
        |> case do {k, _v} -> k end
    b = map
        |> Enum.find(fn {k, v} -> v == ?E end)
        |> case do {k, _v} -> k end
    map = Map.put(map, a, ?a)

    {start, path} = 
      map
      |> Enum.filter(fn {_, v} -> v == ?a end)
      |> Enum.map(fn {k, _} -> k end)
      |> Enum.map(fn a ->
         Pathfinding.a_star(graph, a, b, fn _ -> 0 end)
         |> case do
           nil -> nil
           path -> {a, path}
         end
      end)
      |> Enum.reject(& is_nil/1)
      |> Enum.sort_by(fn {_, path} -> length(path) end)
      |> List.first()

    #show(map, path, start)
    length(path) - 1
  end

  defp show(map, path, start) do
    map = 
      path
      |> Enum.reduce(map, fn a, map ->
        Map.put(map, a, ?.)
      end)
      |> Map.put(start, ?S)

    width = map
            |> Enum.max_by(fn {{x, _}, _} -> x end)
            |> case do {{x, _}, _} -> x end
    height = map
            |> Enum.max_by(fn {{_, y}, _} -> y end)
            |> case do {{_, y}, _} -> y end

    for y <- 0..height do
      for x <- 0..width do
        h = Map.fetch!(map, {x, y})
        h = List.to_string([h])
        IO.write(h)
      end
      IO.puts("")
    end
    IO.puts("")

  end

  defp build_edges(map) do
    map
    |> Map.keys()
    |> Enum.reduce([], fn {xa, ya} = a, edges ->
      height_a = Map.fetch!(map, a)

      [
        {xa + 1, ya},
        {xa - 1, ya},
        {xa, ya - 1},
        {xa, ya + 1}
      ]
      |> Enum.reduce(edges, fn b, edges ->
        height_b = Map.get(map, b, 999)
        edge = {a, b, weight: 1}
        case {height_a, height_b} do
          {?S, ?a} -> [edge | edges]
          {?S, ?b} -> [edge | edges]
          {?y, ?E} -> [edge | edges]
          {?z, ?E} -> [edge | edges]
          {_, ?E} -> edges
          {ha, hb} when hb <= (ha + 1) -> [edge | edges]
          _otherwise -> edges
        end
      end)
    end)
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.to_charlist()
      |> Enum.map(fn
        ?S -> ?S
        ?E -> ?E
        c -> c
      end)
      |> Enum.with_index()
      |> Enum.map(fn {height, x} -> {{x, y}, height} end)
    end)
    |> Enum.into(%{})
  end

end

IO.puts("shortest path from start (part 1): #{Aoc2022.Day12.part1()}")
IO.puts("shortest path from any a (part 2): #{Aoc2022.Day12.part2()}")
