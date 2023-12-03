#!/usr/bin/env elixir
defmodule Aoc2022.Day18 do
  defmodule Cube do
    defstruct [:x, :y, :z]

    def new(x, y, z) do
      %__MODULE__{
        x: x,
        y: y,
        z: z,
      }
    end

    def adjacent(cube, :"+x"), do: %{cube | x: cube.x + 1}
    def adjacent(cube, :"-x"), do: %{cube | x: cube.x - 1}
    def adjacent(cube, :"+y"), do: %{cube | y: cube.y + 1}
    def adjacent(cube, :"-y"), do: %{cube | y: cube.y - 1}
    def adjacent(cube, :"+z"), do: %{cube | z: cube.z + 1}
    def adjacent(cube, :"-z"), do: %{cube | z: cube.z - 1}

    def mini(cube1, cube2) do
      Cube.new(
        min(cube1.x, cube2.x),
        min(cube1.y, cube2.y),
        min(cube1.z, cube2.z)
      )
    end

    def maxi(cube1, cube2) do
      Cube.new(
        max(cube1.x, cube2.x),
        max(cube1.y, cube2.y),
        max(cube1.z, cube2.z)
      )
    end

  end

  def part1 do
    cubes = load()

    cubes
    |> Enum.map(&visible_sides(&1, cubes))
    |> Enum.sum()
  end

  def part2 do
    cubes = load()

    {cube_min, _cube_max} = boundaries = build_boundaries(cubes)
    space = build_space(boundaries)
    external_air = find_external_air(cube_min, MapSet.new(), cubes, boundaries)

    inner_holes =
      space 
      |> MapSet.difference(cubes)
      |> MapSet.difference(external_air)

    inner_surfaces =
      inner_holes
      |> Enum.map(&hole_sides(&1, cubes))
      |> Enum.sum()

    part1() - inner_surfaces
  end

  defp hole_sides(hole, cubes) do
    ~w(+x -x +y -y +z -z)a
    |> Enum.count(fn axis ->
        cube = Cube.adjacent(hole, axis)
        MapSet.member?(cubes, cube)
    end)
  end

  defp build_space({cube_min, cube_max}) do
    for z <- cube_min.z..cube_max.z,
        y <- cube_min.y..cube_max.y,
        x <- cube_min.x..cube_max.x,
        into: MapSet.new(),
        do: Cube.new(x, y, z)
  end

  defp find_external_air(air, external_air, cubes, boundaries) do
    external_air = MapSet.put(external_air, air)

    ~w(+x -x +y -y +z -z)a
    |> Enum.map(&Cube.adjacent(air, &1))
    |> Enum.filter(&inside_boundaries?(&1, boundaries))
    |> Enum.reject(&MapSet.member?(cubes, &1))
    |> Enum.reject(&MapSet.member?(external_air, &1))
    |> Enum.reduce(external_air, fn air, external_air ->
      external_air = MapSet.put(external_air, air)
      find_external_air(air, external_air, cubes, boundaries)
    end)
  end

  defp inside_boundaries?(cube, {cube_min, cube_max}) do
    cube_min.x <= cube.x and cube.x <= cube_max.x and
    cube_min.y <= cube.y and cube.y <= cube_max.y and
    cube_min.z <= cube.z and cube.z <= cube_max.z
  end

  defp build_boundaries(cubes) do
    cubes
    |> Enum.reduce({nil, nil}, fn
      cube, {nil, nil} ->
        {cube, cube}
      cube, {cube_min, cube_max} ->
        {Cube.mini(cube_min, cube), Cube.maxi(cube_max, cube)}
    end)
    |> case do
      {cube_min, cube_max} ->
        {
          ~w(-x -y -z)a |> Enum.reduce(cube_min, &Cube.adjacent(&2, &1)),
          ~w(+x +y +z)a |> Enum.reduce(cube_max, &Cube.adjacent(&2, &1))
        }
    end
  end

  defp visible_sides(%Cube{} = cube, cubes) do
    ~w(+x -x +y -y +z -z)a
    |> Enum.count(fn axis ->
      adjacent = Cube.adjacent(cube, axis)
      not MapSet.member?(cubes, adjacent)
    end)
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_cube/1)
    |> MapSet.new()
  end

  defp parse_cube(row) do
    [x, y, z] = 
      row
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
    Cube.new(x, y, z)
  end

end

IO.puts("surface area (part 1): #{Aoc2022.Day18.part1()}")
IO.puts("exterior surface area (part 2): #{Aoc2022.Day18.part2()}")

