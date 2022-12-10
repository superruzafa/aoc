#!/usr/bin/env elixir
defmodule Aoc2022.Day10 do

  def part1 do
    load()
    |> trace_program()
    |> Enum.with_index(1)
    |> Enum.drop(19)
    |> Enum.take_every(40)
    |> Enum.map(fn {x, cycle} -> x * cycle end)
    |> Enum.sum()
  end

  def part2 do
    load()
    |> trace_program()
    |> Enum.with_index(1)
    |> Enum.map(fn {sprite_pos, cycle} ->
      if sprite_in_pos(sprite_pos, rem(cycle, 40)), do: "#", else: "."
    end)
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end

  defp sprite_in_pos(sprite_pos, cycle) do
    cycle in [sprite_pos, sprite_pos + 1, sprite_pos + 2]
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_instruction("noop"), do: :noop
  defp parse_instruction("addx " <> value), do: {:addx, String.to_integer(value)}

  defp trace_program(instructions) do
    instructions
    |> Enum.flat_map(&expand_instruction/1)
    |> Enum.reduce([1], &perform_cycle/2)
    |> Enum.reverse()
  end

  defp expand_instruction(:noop), do: [:noop]
  defp expand_instruction({:addx, _value} = instruction), do: [:noop, instruction]

  defp perform_cycle(:noop, [x | _rest] = acc), do: [x | acc]
  defp perform_cycle({:addx, value}, [x | _rest] = acc), do: [x + value | acc]
end

IO.puts("sum of signal strengths (part 1): #{Aoc2022.Day10.part1()}")
IO.puts("crt image (part 2):\n\n#{Aoc2022.Day10.part2()}")

