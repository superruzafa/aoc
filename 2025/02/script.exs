#!/bin/env elixir

defmodule Aoc2025.Day02.Shared do
  def parse_input(input) do
    input
    |> File.read!()
    |> parse()
  end

  defp parse(line) do
    line
    |> String.split(",", trim: true)
    |> Enum.map(fn range ->
      [_, min, max] = Regex.run(~r/(\d+)-(\d+)/, range)
      Range.new(parse_integer(min), parse_integer(max))
    end)
  end

  def parse_integer(value) do
    {n, _} = Integer.parse(value)
    n
  end
end

defmodule Aoc2025.Day02.Part1 do
  import Aoc2025.Day02.Shared,
    only: [parse_input: 1]

  def run(input) do
    input
    |> parse_input()
    |> Enum.flat_map(&find_invalid_in_range/1)
    |> Enum.sum()
  end

  defp find_invalid_in_range(min..max//1 = range) do
    digits_min = Integer.digits(min)
    digits_max = Integer.digits(max)

    min = digits_min |> Enum.take(trunc(length(digits_min) / 2)) |> Integer.undigits()
    max = digits_max |> Enum.take(ceil(length(digits_max) / 2)) |> Integer.undigits()

    Range.new(min, max)
    |> Enum.map(&duplicate/1)
    |> Enum.filter(& &1 in range)
  end

  defp duplicate(value) do
    {n, _} = Integer.parse("#{value}#{value}")
    n
  end

end

defmodule Aoc2025.Day02.Part2 do
  import Aoc2025.Day02.Shared,
    only: [parse_input: 1, parse_integer: 1]

  def run(input) do
    input
    |> parse_input()
    |> Enum.flat_map(&find_invalid_in_range/1)
    |> Enum.sum()
  end

  defp find_invalid_in_range(range) do
    range
    |> Enum.filter(&invalid_id?/1)
    |> Enum.reject(& &1 < 10)
  end

  defp invalid_id?(value) do
    digits = Integer.digits(value)
    digits_length = length(digits)

    Range.new(1, div(digits_length + 1, 2))
    |> Stream.map(& duplicate(Enum.take(digits, &1), digits_length))
    |> Enum.any?(& &1 == value)
  end

  defp duplicate(digits_segment, digits_length, acc \\ [])

  defp duplicate(_digits_segment, digits_length, acc) when digits_length == length(acc),
    do: acc |> Enum.join() |> parse_integer()

  defp duplicate(_digits_segment, digits_length, acc) when digits_length < length(acc),
    do: nil

  defp duplicate(digits_segment, digits_length, acc),
    do: duplicate(digits_segment, digits_length, digits_segment ++ acc)

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2025.Day02.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2025.Day02.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

