#!/bin/env elixir

defmodule Aoc2025.Day08.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> MapSet.new()
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

  def build_distances(boxes) do
    boxes
    |> Enum.flat_map(fn box1 ->
      boxes
      |> MapSet.delete(box1)
      |> Enum.map(fn box2 -> {box1, box2, distance(box1, box2)} end)
    end)
    |> Enum.sort_by(fn {_box1, _box2, distance} -> distance end)
    |> Enum.drop_every(2)
    |> Enum.map(fn {box1, box2, _distance} -> {box1, box2} end)
  end

  defp distance({x1, y1, z1}, {x2, y2, z2}) do
    :math.sqrt(
      Integer.pow(x2 - x1, 2) +
        Integer.pow(y2 - y1, 2) +
        Integer.pow(z2 - z1, 2)
    )
  end

  def find_circuit_having_box(circuits, box) do
    Enum.find_index(circuits, &MapSet.member?(&1, box))
  end
end

defmodule Aoc2025.Day08.Part1 do
  import Aoc2025.Day08.Shared

  def run(input) do
    boxes = parse_input(input)

    connections =
      case MapSet.size(boxes) do
        20 -> 10
        1000 -> 1000
      end

    boxes
    |> build_distances()
    |> do_run(connections)
    |> Enum.sort_by(&MapSet.size/1, :desc)
    |> Enum.map(&MapSet.size/1)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp do_run(boxes, connections, circuits \\ [])

  defp do_run([], _connections, circuits), do: circuits

  defp do_run([{box1, box2} | boxes], 0, circuits) do
    circuit1 = find_circuit_having_box(circuits, box1)
    circuit2 = find_circuit_having_box(circuits, box2)

    circuits =
      case {circuit1, circuit2} do
        {nil, nil} -> [MapSet.new([box1]), MapSet.new([box2]) | circuits]
        {nil, _index2} -> [MapSet.new([box1]) | circuits]
        {_index1, nil} -> [MapSet.new([box2]) | circuits]
        {_index1, _index2} -> circuits
      end

    do_run(boxes, 0, circuits)
  end

  defp do_run([{box1, box2} | boxes], connections, circuits) do
    circuit1 = find_circuit_having_box(circuits, box1)
    circuit2 = find_circuit_having_box(circuits, box2)

    circuits =
      case {circuit1, circuit2} do
        {nil, nil} ->
          [MapSet.new([box1, box2]) | circuits]

        {index1, nil} ->
          List.update_at(circuits, index1, &MapSet.put(&1, box2))

        {nil, index2} ->
          List.update_at(circuits, index2, &MapSet.put(&1, box1))

        {index, index} ->
          circuits

        {index1, index2} ->
          {circuit1, circuits} = List.pop_at(circuits, index1)
          index2 = if index1 < index2, do: index2 - 1, else: index2
          {circuit2, circuits} = List.pop_at(circuits, index2)

          [MapSet.union(circuit1, circuit2) | circuits]
      end

    do_run(boxes, connections - 1, circuits)
  end
end

defmodule Aoc2025.Day08.Part2 do
  import Aoc2025.Day08.Shared

  def run(input) do
    boxes = parse_input(input)
    circuits = Enum.map(boxes, &MapSet.new([&1]))

    boxes
    |> build_distances()
    |> do_run(circuits)
  end

  defp do_run([{box1, box2} | boxes], circuits) do
    circuit1 = find_circuit_having_box(circuits, box1)
    circuit2 = find_circuit_having_box(circuits, box2)

    case {circuit1, circuit2} do
      {nil, nil} ->
        do_run(boxes, [MapSet.new([box1, box2]) | circuits])

      {index1, nil} ->
        circuits
        |> List.update_at(index1, &MapSet.put(&1, box2))
        |> then(&do_run(boxes, &1))

      {nil, index2} ->
        circuits
        |> List.update_at(index2, &MapSet.put(&1, box1))
        |> then(&do_run(boxes, &1))

      {index, index} ->
        do_run(boxes, circuits)

      {index1, index2} ->
        {circuit1, circuits} = List.pop_at(circuits, index1)
        index2 = if index1 < index2, do: index2 - 1, else: index2
        {circuit2, circuits} = List.pop_at(circuits, index2)

        case [MapSet.union(circuit1, circuit2) | circuits] do
          [_circuit] ->
            {x1, _, _} = box1
            {x2, _, _} = box2
            x1 * x2

          circuits ->
            do_run(boxes, circuits)
        end
    end
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day08.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day08.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end
