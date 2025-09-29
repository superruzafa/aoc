#!/bin/env elixir

defmodule Aoc2024.Day3 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.flat_map(fn
      {:mul, op1, op2} -> [op1 * op2]
      _ -> []
    end)
    |> Enum.sum()
  end

  def part2(input) do
    {_, sum} =
      input
      |> parse_input()
      |> Enum.reduce({:do, 0}, fn
        :do, {_, sum} -> {:do, sum}
        :dont, {_, sum} -> {:dont, sum}
        {:mul, _, _}, {:dont, sum} -> {:dont, sum}
        {:mul, op1, op2}, {:do, sum} -> {:do, sum + op1 * op2}
      end)

    sum
  end

  defp parse_input(input) do
    input
    |> File.read!()
    |> then(&Regex.scan(~r/(?:do\(\))|(?:don't\(\))|(?:mul\((\d{1,3}),(\d{1,3})\))/, &1))
    |> Enum.map(fn
      [_, op1, op2] -> {:mul, parse_integer(op1), parse_integer(op2)}
      ["do()"] -> :do
      ["don't()"] -> :dont
    end)
  end

  defp parse_integer(value) do
    {integer, _} = Integer.parse(value)
    integer
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2024.Day3.part1(input)}")
    IO.puts("Part 2: #{Aoc2024.Day3.part2(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

