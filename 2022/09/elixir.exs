#!/usr/bin/env elixir
defmodule Aoc2022.Day9.Position do
  defstruct [:x, :y]

  def new(x, y) do
    %__MODULE__{x: x, y: y}
  end

  def add(pos, x, y), do: new(pos.x + x, pos.y + y)

  def move(pos, :up), do: new(pos.x, pos.y - 1)
  def move(pos, :down), do: new(pos.x, pos.y + 1)
  def move(pos, :right), do: new(pos.x + 1, pos.y)
  def move(pos, :left), do: new(pos.x - 1, pos.y)

  def move(pos, :up, :right), do: new(pos.x + 1, pos.y - 1)
  def move(pos, :up, :left), do: new(pos.x - 1, pos.y - 1)
  def move(pos, :down, :right), do: new(pos.x + 1, pos.y + 1)
  def move(pos, :down, :left), do: new(pos.x - 1, pos.y + 1)
end

defmodule Aoc2022.Day9 do

  import Aoc2022.Day9.Position

  def part1 do
    tail = head = new(0, 0)
    acc = %{
      head: head,
      tail: tail,
      positions: [tail]
    }

    load_movements()
    |> Enum.reduce(acc, &reducer_part1/2)
    |> Map.fetch!(:positions)
    |> Enum.uniq()
    |> length()
  end

  def part2 do
    knots_length = 10
    knots = for i <- 1..knots_length, into: %{}, do: {i, new(0, 0)}
    acc = %{
      knots: knots, 
      positions: [new(0, 0)]
    }

    load_movements()
    |> Enum.reduce(acc, &reducer_part2/2)
    |> Map.fetch!(:positions)
    |> Enum.uniq()
    |> length()
  end

  defp opposite(:up), do: :down
  defp opposite(:down), do: :up
  defp opposite(:right), do: :left
  defp opposite(:left), do: :right

  defp reducer_part1(dir, %{head: head, tail: tail, positions: positions}) do
    new_head = move(head, dir)
    if adjacent_knots?(new_head, tail) do
      %{head: new_head, tail: tail, positions: positions}
    else
      new_tail = move(new_head, opposite(dir))
      %{head: new_head, tail: new_tail, positions: [new_tail | positions]}
    end
  end

  defp reducer_part2(dir, %{knots: knots, positions: positions}) do
    knots = Map.update!(knots, 1, & move(&1, dir))
    adjust_knots(1, %{knots: knots, positions: positions})
  end

  defp adjacent_knots?(head, tail) do
    around = for y <- -1..+1, x <- -1..+1, do: add(head, x, y)
    tail in around
  end

  defp knots_in_same_row?(%{x: x1}, %{x: x2}), do: x1 == x2

  defp knots_in_same_col?(%{y: y1}, %{y: y2}), do: y1 == y2

  defp knots_in_same_row_or_col?(k1, k2) do
    knots_in_same_row?(k1, k2) or knots_in_same_col?(k1, k2)
  end

  defp adjust_knots(i, %{knots: knots} = acc) do
    j = i + 1
    knoti = Map.fetch!(knots, i)
    knotj = Map.fetch!(knots, j)
    cond do
      adjacent_knots?(knoti, knotj) ->
        acc

      knots_in_same_row_or_col?(knoti, knotj) ->
        knotj = [
          move(knotj, :up),
          move(knotj, :down),
          move(knotj, :left),
          move(knotj, :right)
        ]
        |> Enum.find(& adjacent_knots?(knoti, &1))

        knots = Map.put(knots, j, knotj)
        if i == map_size(knots) - 1 do
          %{acc | knots: knots, positions: [knotj | acc.positions]}
        else
          adjust_knots(j, %{acc | knots: knots})
        end

      true ->
        knotj = [
          move(knotj, :up, :right),
          move(knotj, :up, :left),
          move(knotj, :down, :right),
          move(knotj, :down, :left),
        ]
        |> Enum.find(& adjacent_knots?(knoti, &1))

        knots = Map.put(knots, j, knotj)
        if i == 9 do
          %{acc | knots: knots, positions: [knotj | acc.positions]}
        else
          adjust_knots(j, %{acc | knots: knots})
        end
    end
  end
 
  defp load_movements do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_movement/1)
    |> Enum.flat_map(&walk/1)
  end

  defp parse_movement(line) do
    ~r/(?<dir>\w) (?<times>\d+)/
    |> Regex.named_captures(line)
    |> case do
      %{"dir" => dir, "times" => times} ->
        {parse_direction(dir), String.to_integer(times)}
    end
  end

  defp parse_direction("U"), do: :up
  defp parse_direction("D"), do: :down
  defp parse_direction("L"), do: :left
  defp parse_direction("R"), do: :right

  defp walk({dir, times}), do: List.duplicate(dir, times)
end

IO.puts("# positions visited by tail (part 1): #{Aoc2022.Day9.part1()}")
IO.puts("# positions visited by tail (part 2): #{Aoc2022.Day9.part2()}")

