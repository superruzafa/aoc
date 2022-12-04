#!/usr/bin/env elixir
defmodule Aoc2022.Day4.Part1 do
  def run do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_pair/1)
    |> Enum.count(fn [a1, a2] -> any_assignment_contained?(a1, a2) end)
  end

  def parse_pair(line) do
    line
    |> String.split(",")
    |> Enum.map(&parse_assignment/1)
  end

  def parse_assignment(assignment) do
    [first, last] =
      assignment
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)

    Range.new(first, last)
  end

  defp any_assignment_contained?(assignment1, assignment2) do
    assignment_fully_contained?(assignment1, assignment2) or
      assignment_fully_contained?(assignment2, assignment1)
  end
    
  defp assignment_fully_contained?(first1..last1 = _overlapped, first2..last2 = _overlapper) do
    first1 >= first2 and last1 <= last2
  end

end

defmodule Aoc2022.Day4.Part2 do

  import Aoc2022.Day4.Part1, only: [parse_pair: 1]

  def run do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_pair/1)
    |> Enum.count(fn [a1, a2] -> assignment_partially_contained?(a1, a2) end)
  end

  defp assignment_partially_contained?(assignment1, assignment2) do
    not Range.disjoint?(assignment1, assignment2)
  end

end

IO.puts("Assignments overlapping (part 1): #{Aoc2022.Day4.Part1.run()}")
IO.puts("Assignments overlapping (part 2): #{Aoc2022.Day4.Part2.run()}")

