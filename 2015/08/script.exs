#!/bin/env elixir

defmodule Aoc2015.Day08.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end

defmodule Aoc2015.Day08.Part1 do
  import Aoc2015.Day08.Shared,
    only: [parse_input: 1]

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&lengths/1)
    |> Enum.unzip()
    |> case do
      {code_lengths, memory_lengths} ->
        Enum.sum(code_lengths) - Enum.sum(memory_lengths)
    end
  end

  defp lengths(line) do
    {
      String.length(line),
      line
      |> Code.eval_string()
      |> case do
        {string, []} -> String.length(string)
      end
    }
  end
end

defmodule Aoc2015.Day08.Part2 do
  import Aoc2015.Day08.Shared,
    only: [parse_input: 1]

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&lengths/1)
    |> Enum.unzip()
    |> case do
      {literal_lengths, encoded_length} ->
        Enum.sum(encoded_length) - Enum.sum(literal_lengths)
    end
  end

  defp lengths(line) do
    {
      String.length(line),
      line
      |> inspect()
      |> String.length()
    }
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day08.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day08.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

