#!/bin/env elixir

defmodule Aoc2025.Day06.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def parse_integer(value) do
    {n, _} = Integer.parse(value)
    n
  end
end

defmodule Aoc2025.Day06.Part1 do
  import Aoc2025.Day06.Shared

  def run(input) do
    input
    |> parse_input()
    |> parse_lines()
    |> do_run()
  end

  defp parse_lines(lines) do
    lines
    |> Enum.split(-1)
    |> then(fn {numbers_list, [operators]} ->
      Enum.map(numbers_list, &parse_numbers/1) ++ [parse_operators(operators)]
    end)
  end

  defp parse_numbers(numbers) do
    ~r/\s+/
    |> Regex.split(numbers, trim: true)
    |> Enum.map(&parse_integer/1)
  end

  defp parse_operators(operators) do
    Regex.split(~r/\s+/, operators, trim: true)
  end

  defp do_run(numbers_ops, acc \\ 0)

  defp do_run([[] | _rest], acc), do: acc

  defp do_run(numbers_ops, acc) do
    {column, numbers_ops} =
      numbers_ops
      |> Enum.reduce({[], []}, fn [head | tail], {col_acc, row_acc} ->
        {[head | col_acc], row_acc ++ [tail]}
      end)

    do_run(numbers_ops, acc + do_operation(column))
  end

  defp do_operation(["+" | numbers]), do: Enum.sum(numbers)

  defp do_operation(["*" | numbers]), do: Enum.product(numbers)
end

defmodule Aoc2025.Day06.Part2 do
  import Aoc2025.Day06.Shared

  def run(input) do
    lines = parse_input(input)

    max_length =
      lines
      |> Enum.map(&String.length/1)
      |> Enum.max()

    do_run(lines, max_length - 1)
  end

  defp do_run(lines, column, numbers \\ [0], acc \\ 0)

  defp do_run(_lines, -1, _numbers, acc), do: acc

  defp do_run(lines, col, numbers, acc) do
    {numbers, acc} =
      Enum.reduce(
        lines,
        {numbers, acc},
        fn line, {numbers, acc} ->
          case String.at(line, col) do
            char when char in [" ", nil] -> {numbers, acc}
            "+" -> {[], acc + Enum.sum(numbers)}
            "*" -> {[], acc + Enum.product(numbers)}
            n ->
              [curr | rest] = numbers
              {[curr * 10 + parse_integer(n) | rest], acc}
        end
      end)

    numbers = Enum.reject(numbers, & &1 == 0)
    do_run(lines, col - 1, [0 | numbers], acc)
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day06.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day06.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

