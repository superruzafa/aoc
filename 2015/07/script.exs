#!/bin/env elixir

defmodule Aoc2015.Day07.Cache do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def reset do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end

  def get_lazy(key, fun) do
    case Agent.get(__MODULE__, &Map.get(&1, key)) do
      nil ->
        value = fun.()
        Agent.update(__MODULE__, &Map.put(&1, key, value))
        value

      value ->
        value
    end
  end
end

defmodule Aoc2015.Day07.Shared do
  alias Aoc2015.Day07.Cache

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Map.new(&parse_operation/1)
  end

  defp parse_operation(line) do
    [
      &parse_assign/1,
      &parse_boolean_binary_op/1,
      &parse_boolean_not_op/1,
      &parse_shift_op/1,
      &parse_unsupported/1
    ]
    |> Enum.find_value(fn fun -> fun.(line) end)
  end

  defp parse_assign(line) do
    case Regex.run(~r/^(\w+) -> (\w+)$/, line) do
      [_, in1, out] -> {out, {:assign, in1}}
      nil -> nil
    end
  end

  defp parse_boolean_binary_op(line) do
    case Regex.run(~r/^(\w+) (AND|OR) (\w+) -> (\w+)$/, line) do
      [_, in1, op, in2, out] ->
        op = op |> String.downcase() |> String.to_atom()
        {out, {op, in1, in2}}

      nil ->
        nil
    end
  end

  defp parse_boolean_not_op(line) do
    case Regex.run(~r/^(NOT) (\w+) -> (\w+)$/, line) do
      [_, op, in1, out] ->
        op = op |> String.downcase() |> String.to_atom()
        {out, {op, in1}}

      nil ->
        nil
    end
  end

  defp parse_shift_op(line) do
    case Regex.run(~r/^(\w+) (LSHIFT|RSHIFT) (\d+) -> (\w+)$/, line) do
      [_, in1, op, value, out] ->
        op = op |> String.downcase() |> String.to_atom()
        {out, {op, in1, parse_integer(value)}}

      nil ->
        nil
    end
  end

  defp parse_unsupported(line) do
    raise line
  end

  defp parse_integer(value) do
    {n, _} = Integer.parse(value)
    n
  end

  def eval(circuit, wire) do
    Cache.get_lazy(wire, fn -> do_eval(circuit, wire) end)
  end

  defp do_eval(circuit, wire) do
    case Integer.parse(wire) do
      {n, ""} ->
        n

      :error ->
        case Map.fetch!(circuit, wire) do
          {:assign, in1} -> eval(circuit, in1)
          {:and, in1, in2} -> Bitwise.&&&(eval(circuit, in1), eval(circuit, in2))
          {:or, in1, in2} -> Bitwise.|||(eval(circuit, in1), eval(circuit, in2))
          {:rshift, in1, value} -> Bitwise.bsr(eval(circuit, in1), value)
          {:lshift, in1, value} -> Bitwise.bsl(eval(circuit, in1), value)
          {:not, in1} -> Bitwise.bnot(eval(circuit, in1))
        end
    end
  end

  def to_unsigned_16(value) do
    rem(rem(value, 65536) + 65536, 65536)
  end
end

defmodule Aoc2015.Day07.Part1 do
  import Aoc2015.Day07.Shared

  alias Aoc2015.Day07.Cache

  def run(input, wire \\ "a") do
    input
    |> parse_input()
    |> eval(wire)
    |> to_unsigned_16()
  end
end

defmodule Aoc2015.Day07.Part2 do
  import Aoc2015.Day07.Shared

  alias Aoc2015.Day07.Cache
  alias Aoc2015.Day07.Part1

  def run(input, wire) do
    value = Part1.run(input, wire)

    Cache.reset()

    input
    |> parse_input()
    |> Map.put("b", {:assign, "#{value}"})
    |> eval(wire)
    |> to_unsigned_16()
  end
end

Aoc2015.Day07.Cache.start_link()

case System.argv() do
  [input, wire | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day07.Part1.run(input, wire)}")
    IO.puts("Part 2: #{Aoc2015.Day07.Part2.run(input, wire)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT WIRE")
end
