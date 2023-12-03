#!/usr/bin/env elixir
defmodule Aoc2022.Day1 do
  def part_1 do
    File.read!("./input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(&sum_elf_calories/1)
    |> Enum.max()
  end

  def part_2 do
    File.read!("./input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(&sum_elf_calories/1)
    |> Enum.sort(&>=/2)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp sum_elf_calories(elf_line) do
    elf_line
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end
end

IO.puts("Top calories: #{Aoc2022.Day1.part_1()}")
IO.puts("Total of top 3 calories: #{Aoc2022.Day1.part_2()}")

