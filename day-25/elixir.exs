#!/usr/bin/env elixir
defmodule Aoc2022.Day25 do

  def part1 do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn n -> snafu_to_dec(n) end)
    |> Enum.sum()
    |> dec_to_snafu()
  end

  def snafu_to_dec(snafu) do
    snafu
    |> String.codepoints()
    |> Enum.map(&symbol_to_dec/1)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {value, pow}, acc ->
      acc + value * 5 ** pow
    end)
  end

  defp symbol_to_dec("2"), do: 2
  defp symbol_to_dec("1"), do: 1
  defp symbol_to_dec("0"), do: 0
  defp symbol_to_dec("-"), do: -1
  defp symbol_to_dec("="), do: -2

  @symbols ~w(2 1 0 - =)a

  defp generate do
    start =
      %{
        :exp => 0,
        :"2" => 2,
        :"1" => 1,
        :"0" => 0,
        :"-" => -1,
        :"=" => -2,
        :min => -2,
        :max => 2
      }

    Stream.iterate(start, fn m ->
      exp = m.exp + 1
      a1 = 5 ** exp
      a2 = 2 * a1
      %{
        :exp => exp,
        :"2" => a2,
        :"1" => a1,
        :"0" => 0,
        :"-" => -a1,
        :"=" => -a2,
        :max => m.max + a2,
        :min => m.max + 1,
      }
    end)
  end

  def dec_to_snafu(dec) do
    cosas =
      generate()
      |> Enum.take_while(fn %{min: min} -> min < dec end)
      |> Enum.reverse()

    find_snafu(dec, cosas, [])
  end

  defp find_snafu(_dec, [], acc) do
    acc
    |> Enum.reverse()
    |> Enum.join()
  end

  defp find_snafu(dec, [head | tail], acc) do
    head
    |> Map.take(@symbols)
    |> Enum.min_by(fn {_k, v} -> abs(dec - v) end)
    |> case do
      {symbol, amount} ->
        find_snafu(dec - amount, tail, [symbol | acc])
    end

  end

end

IO.puts("SNAFU number (part 1): #{Aoc2022.Day25.part1()}")

