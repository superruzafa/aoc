#!/usr/bin/env elixir
defmodule Aoc2022.Day6.Part1 do
  def run do
    "./input.txt"
    |> File.read!()
    |> String.codepoints()
    |> Enum.chunk_every(4, 1)
    |> Enum.with_index(4)
    |> Enum.find(&is_marker?/1)
    |> case do {_sequence, pos} -> pos end
  end

  defp is_marker?({sequence, pos}) do
    sequence
    |> Enum.uniq()
    |> length() == 4
  end
end

defmodule Aoc2022.Day6.Part2 do
  def run do
    "./input.txt"
    |> File.read!()
    |> String.codepoints()
    |> Enum.chunk_every(14, 1)
    |> Enum.with_index(14)
    |> Enum.find(&is_marker?/1)
    |> case do {_sequence, pos} -> pos end
  end

  defp is_marker?({sequence, pos}) do
    sequence
    |> Enum.uniq()
    |> length() == 14
  end
end

IO.puts("Start of packet marker (part 1): #{Aoc2022.Day6.Part1.run()}")
IO.puts("Start of packet marker (part 2): #{Aoc2022.Day6.Part2.run()}")

