#!/usr/bin/env elixir
defmodule Aoc2022.Day3.Part1 do
  def run do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&process_rucksack/1)
    |> Enum.sum()
  end

  defp process_rucksack(line) do
    line
    |> split_compartments()
    |> case do {items1, items2} -> find_common(items1, items2) end
    |> priority_of()
  end

  defp split_compartments(line), do:
    String.split_at(line, div(String.length(line), 2))

  def find_common(items1, items2) do
    items1 = String.split(items1, "", trim: true)
    items2 = String.split(items2, "", trim: true)

    items1
    |> Enum.filter(fn item -> item in items2 end)
    |> Enum.uniq()
    |> Enum.join()
  end

  def priority_of(item) do
    if item == String.upcase(item) do
      hd(to_charlist(item)) - ?A + 27
    else
      hd(to_charlist(item)) - ?a + 1
    end
  end
end

defmodule Aoc2022.Day3.Part2 do
  import Aoc2022.Day3.Part1, only: [find_common: 2, priority_of: 1]
  def run do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(&process_rucksacks/1)
    |> Enum.map(&priority_of/1)
    |> Enum.sum()
  end

  defp process_rucksacks([rucksack1, rucksack2]) do
    find_common(rucksack1, rucksack2)
  end

  defp process_rucksacks([rucksack1, rucksack2 | rucksacks]) do
    process_rucksacks([find_common(rucksack1, rucksack2) | rucksacks])
  end

end

IO.puts("Sum priorities (part 1): #{Aoc2022.Day3.Part1.run()}")
IO.puts("Sum priorities (part 2): #{Aoc2022.Day3.Part2.run()}")

