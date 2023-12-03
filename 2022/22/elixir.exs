#!/usr/bin/env elixir

defmodule Aoc2022.Day22.Shared do

  @directions ~w(right down left up)a

  def directions, do: @directions

  def direction_value(direction) do
    Enum.find_index(@directions, &Kernel.==(&1, direction))
  end

  def turn(direction, turning_direction) do
    index = direction_value(direction)
    index =
      case turning_direction do
        :turn_right -> index + 1
        :turn_left -> index - 1
      end
      |> rem(length(@directions))
    Enum.at(@directions, index)
  end

  @digits ~w(0 1 2 3 4 5 6 7 8 9)

  def parse_path(line) do
    line
    |> String.codepoints()
    |> Enum.chunk_by(fn codepoint ->
      case codepoint do
        cp when cp in @digits -> :number
        _ -> :alpha
      end
    end)
    |> Enum.map(fn
      ["\n"] -> nil
      ["R"] -> :turn_right
      ["L"] -> :turn_left
      digits -> digits |> Enum.map(&String.to_integer/1) |> Integer.undigits()
    end)
    |> Enum.reject(&is_nil/1)
  end
end

defmodule Aoc2022.Day22.Part1 do

  alias Aoc2022.Day22.Shared

  def run(map, xy, direction, path) do
    run_steps(map, xy, direction, path)
  end

  defp run_steps(_map, xy, _direction, []), do: xy

  defp run_steps(map, xy, direction, [steps | tail]) do
    xy = step_all(map, xy, direction, steps)
    run_turn(map, xy, direction, tail)
  end

  defp run_turn(_map, xy, direction, []), do: {xy, direction}

  defp run_turn(map, xy, direction, [turning_direction | tail]) do
    direction = Shared.turn(direction, turning_direction)
    run_steps(map, xy, direction, tail)
  end

  defp step_all(_map, xy, _direction, 0), do: xy

  defp step_all(map, xy, direction, steps) do
    next_xy = step_one(xy, direction)

    case Map.get(map, next_xy, :wrap) do
      :path -> {:path, next_xy}
      :wall -> {:wall, xy}
      :wrap -> 
        next_next_xy = step_wrap(map, direction, next_xy)
        case Map.fetch!(map, next_next_xy) do
          :path -> {:path, next_next_xy}
          :wall -> {:wall, xy}
        end
    end
    #|> IO.inspect()
    |> case do
      {:path, next_xy} -> step_all(map, next_xy, direction, steps - 1)
      {:wall, xy} -> xy
    end
  end

  defp step_one({x, y}, :left), do: {x - 1, y}
  defp step_one({x, y}, :right), do: {x + 1, y}
  defp step_one({x, y}, :up), do: {x, y - 1}
  defp step_one({x, y}, :down), do: {x, y + 1}

  def find_start(map) do
    step_wrap(map, :right, {0, 0})
  end

  defp step_wrap(map, :right, {_x, y}) do
    map
    |> Map.keys()
    |> Enum.filter(fn
      {_, ^y} -> true
      _ -> false
    end)
    |> Enum.min_by(fn {x, _} -> x end)
  end

  defp step_wrap(map, :left, {_x, y}) do
    map
    |> Map.keys()
    |> Enum.filter(fn
      {_, ^y} -> true
      _ -> false
    end)
    |> Enum.max_by(fn {x, _} -> x end)
  end

  defp step_wrap(map, :up, {x, _y}) do
    map
    |> Map.keys()
    |> Enum.filter(fn
      {^x, _} -> true
      _ -> false
    end)
    |> Enum.max_by(fn {_, y} -> y end)
  end

  defp step_wrap(map, :down, {x, _y}) do
    map
    |> Map.keys()
    |> Enum.filter(fn
      {^x, _} -> true
      _ -> false
    end)
    |> Enum.min_by(fn {_, y} -> y end)
  end

  def load do
    [map_line, path_line] =
      "./input.txt"
      |> File.read!()
      |> String.split("\n\n", trim: true)

    {
      parse_map(map_line),
      Shared.parse_path(path_line)
    }
  end

  defp parse_map(map_line) do
    map_line
    |> String.split("\n", trim: true)
    |> Enum.with_index(0)
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index(0)
      |> Enum.map(fn
        {".", x} -> {{x, y}, :path}
        {"#", x} -> {{x, y}, :wall}
        _ -> nil
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.into(%{})
  end

end

defmodule Aoc2022.Day22.Part2 do

  alias Aoc2022.Day22.Shared

  #       [A]
  # [B][C][D]
  #       [E][F]

  #@face_size 4

  #@faces_xy %{
    #a: {2, 0},
    #b: {0, 1},
    #c: {1, 1},
    #d: {2, 1},
    #e: {2, 2},
    #f: {3, 2}
  #}

  #@face_relationships %{
    #{:a, :right} => {:f, :left},
    #{:a, :down}  => {:d, :down},
    #{:a, :left}  => {:c, :down},
    #{:a, :up}    => {:b, :down},

    #{:b, :right} => {:c, :right},
    #{:b, :down}  => {:e, :up},
    #{:b, :left}  => {:f, :up},
    #{:b, :up}    => {:a, :down},

    #{:c, :right} => {:d, :right},
    #{:c, :down}  => {:e, :right},
    #{:c, :left}  => {:b, :left},
    #{:c, :up}    => {:a, :right},

    #{:d, :right} => {:f, :down},
    #{:d, :down}  => {:e, :down},
    #{:d, :left}  => {:c, :left},
    #{:d, :up}    => {:a, :up},

    #{:e, :right} => {:f, :right},
    #{:e, :down}  => {:b, :up},
    #{:e, :left}  => {:c, :up},
    #{:e, :up}    => {:d, :up},

    #{:f, :right} => {:a, :left},
    #{:f, :down}  => {:b, :right},
    #{:f, :left}  => {:e, :left},
    #{:f, :up}    => {:d, :left},
  #}

  #    [A][B]
  #    [C]
  # [D][E]
  # [F]

  @face_size 50

  @faces_xy %{
    a: {1, 0},
    b: {2, 0},
    c: {1, 1},
    d: {0, 2},
    e: {1, 2},
    f: {0, 3}
  }

  @face_relationships %{
    {:a, :right} => {:b, :right},
    {:a, :down}  => {:c, :down},
    {:a, :left}  => {:d, :right},
    {:a, :up}    => {:f, :right},

    {:b, :right} => {:e, :left},
    {:b, :down}  => {:c, :left},
    {:b, :left}  => {:a, :left},
    {:b, :up}    => {:f, :up},

    {:c, :right} => {:b, :up},
    {:c, :down}  => {:e, :down},
    {:c, :left}  => {:d, :down},
    {:c, :up}    => {:a, :up},

    {:d, :right} => {:e, :right},
    {:d, :down}  => {:f, :down},
    {:d, :left}  => {:a, :right},
    {:d, :up}    => {:c, :right},

    {:e, :right} => {:b, :left},
    {:e, :down}  => {:f, :left},
    {:e, :left}  => {:d, :left},
    {:e, :up}    => {:c, :up},

    {:f, :right} => {:e, :up},
    {:f, :down}  => {:b, :down},
    {:f, :left}  => {:a, :down},
    {:f, :up}    => {:d, :up},
  }

  def run(faces, face, xy, direction, path) do
    run_steps(faces, face, xy, direction, path)
  end

  defp run_steps(_faces, face, xy, direction, []), do: {face, xy, direction}

  defp run_steps(faces, face, xy, direction, [steps | tail]) do
    {face, xy, direction} = step_all(faces, face, xy, direction, steps)
    run_turn(faces, face, xy, direction, tail)
  end

  defp step_all(_faces, face, xy, direction, 0), do: {face, xy, direction}

  defp step_all(faces, face, xy, direction, steps) do
    next_xy = step_one(xy, direction)

    faces
    |> Map.fetch!(face)
    |> Map.get(next_xy, :out) 
    |> case do
      :path -> {:path, face, next_xy, direction}
      :wall -> {:wall, xy}
      :out -> 
        {next_face, next_next_xy, next_direction} = step_face(face, xy, direction)
        faces
        |> Map.fetch!(next_face)
        |> Map.get(next_next_xy)
        |> case do
          :path -> {:path, next_face, next_next_xy, next_direction}
          :wall -> {:wall, xy}
        end
    end
    |> case do
      {:path, face, xy, direction} ->
        step_all(faces, face, xy, direction, steps - 1)

      {:wall, xy} ->
        {face, xy, direction}
    end
  end

  defp step_one({x, y}, :right), do: {x + 1, y}
  defp step_one({x, y}, :down), do: {x, y + 1}
  defp step_one({x, y}, :left), do: {x - 1, y}
  defp step_one({x, y}, :up), do: {x, y - 1}

  defp step_face(face, {x, y}, direction) do
    {target_face, target_direction} = Map.fetch!(@face_relationships, {face, direction})

    inv = fn a -> @face_size - 1 - a end
    max = @face_size - 1

    xy =
      case {direction, target_direction} do
        {:down, :left} -> {max, x}
        {:down, :up} -> {inv.(x), max}
        {:down, :right} -> {0, inv.(x)}
        {:down, :down} -> {x, 0}

        {:left, :left} -> {max, y}
        {:left, :up} -> {y, max}
        {:left, :right} -> {0, inv.(y)}
        {:left, :down} -> {y, 0}

        {:right, :left} -> {max, max - y}
        {:right, :up} -> {y, max}
        {:right, :right} -> {0, y}
        {:right, :down} -> {inv.(y), 0}

        {:up, :left} -> {0, x}
        {:up, :up} -> {x, max}
        {:up, :right} -> {0, x}
        {:up, :down} -> {inv.(x), 0}
      end
    {target_face, xy, target_direction}

  end

  defp run_turn(_faces, face, xy, direction, []), do: {face, xy, direction}

  defp run_turn(faces, face, xy, direction, [turning_direction | tail]) do
    direction = Shared.turn(direction, turning_direction)
    run_steps(faces, face, xy, direction, tail)
  end

  def unfold(face, {x, y}) do
    {bx, by} = Map.fetch!(@faces_xy, face)
    {bx * @face_size + x, by * @face_size + y}
  end

  def load do
    [faces, path] =
      "./input.txt"
      |> File.read!()
      |> String.split("\n\n", trim: true)

    faces = 
      faces
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.codepoints()
        |> Enum.chunk_every(@face_size)
      end)
      |> Enum.chunk_every(@face_size)

    cube = @faces_xy
           |> Enum.map(fn {k, xy} -> {k, parse_face(faces, xy)} end)
           |> Enum.into(%{})

    path = Shared.parse_path(path)

    {cube, path}
  end

  defp parse_face(faces, {x, y}) do
    faces
    |> Enum.at(y)
    |> Enum.map(&Enum.at(&1, x))
    |> Enum.with_index(0)
    |> Enum.flat_map(fn {aaa, y} ->
      aaa
      |> Enum.with_index(0)
      |> Enum.map(fn
        {".", x} -> {{x, y}, :path}
        {"#", x} -> {{x, y}, :wall}
      end)
    end)
    |> Enum.into(%{})
  end

end

defmodule Aoc2022.Day22 do

  alias __MODULE__.{Part1, Part2, Shared}

  def part1 do
    {map, path} = Part1.load()
    start = Part1.find_start(map)
    {{x, y}, direction} = Part1.run(map, start, :right, path)
    1000 * (y + 1) + 4 * (x + 1) + Shared.direction_value(direction)
  end

  def part2 do
    {faces, path} = Part2.load()
    {face, {x, y}, direction} = Part2.run(faces, :a, {0, 0}, :right, path)
    {x, y} = Part2.unfold(face, {x, y})
    1000 * (y + 1) + 4 * (x + 1) + Shared.direction_value(direction)
  end
end

IO.puts("final password (part 1): #{Aoc2022.Day22.part1()}")
IO.puts("final password (part 2): #{Aoc2022.Day22.part2()}")

