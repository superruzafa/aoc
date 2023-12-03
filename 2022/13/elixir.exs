#!/usr/bin/env elixir
defmodule Aoc2022.Day13 do

  def part1 do
    load()
    |> Enum.with_index(1)
    |> Enum.filter(fn {{expr1, expr2}, _index} ->
      case compare(expr1, expr2) do
        :lt -> true
        :eq -> true
        _otherwise -> false
      end
    end)
    |> Enum.map(fn {_exprs, index} -> index end)
    |> Enum.sum()
  end

  def part2 do
    additional = [ [[2]], [[6]] ]

    load()
    |> Enum.flat_map(fn {expr1, expr2} -> [expr1, expr2] end)
    |> case do exprs -> additional ++ exprs end
    |> Enum.sort_by(&Function.identity/1, fn expr1, expr2 ->
      case compare(expr1, expr2) do
        :lt -> true
        :eq -> true
        _otherwise -> false
      end
    end)
    |> Enum.with_index(1)
    |> Enum.filter(fn
      {[[2]], _index} -> true
      {[[6]], _index} -> true
      _otherwise -> false
    end)
    |> Enum.map(fn {_expr, index} -> index end)
    |> Enum.product()
  end

  def load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_pair/1)
  end

  defp compare(a, b) when is_integer(a) and is_integer(b) do
    cond do
      a == b -> :eq
      a < b -> :lt
      true -> :gt
    end
  end

  defp compare([], []), do: :eq

  defp compare([], [_b | _bs]), do: :lt

  defp compare([_a | _as], []), do: :gt

  defp compare([a | as], [b | bs]) do
    case compare(a, b) do
      :eq -> compare(as, bs)
      otherwise -> otherwise
    end
  end

  defp compare(a, b), do: compare(List.wrap(a), List.wrap(b))

  defp parse_pair(line) do
    line
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&scan(&1, []))
    |> Enum.map(&parse/1)
    |> case do [expr1, expr2] -> {expr1, expr2} end
  end

  defp parse([token | _] = tokens) do
    case token do
      :open_bracket -> parse_list(tokens)
      n when is_integer(n) -> n

    end
    |> case do {expr, []} -> expr end
  end

  defp parse_list(tokens) do
    [:open_bracket | tokens] = tokens
    {list, tokens} = parse_list_contents(tokens, [])
    [:close_bracket | tokens] = tokens

    {list, tokens}
  end

  defp parse_list_contents([token | tail] = tokens, list) do
    case token do
      :close_bracket ->
        list = Enum.reverse(list)
        {list, tokens}

      n when is_integer(n) ->
        list = [n | list]
        parse_list_contents_2(tail, list)

      :open_bracket ->
        {inner_list, tokens} = parse_list(tokens)
        list = [inner_list | list]
        parse_list_contents_2(tokens, list)
    end
  end

  defp parse_list_contents_2([token | _] = tokens, list) do
    case token do
      :comma ->
        [:comma | tokens] = tokens
        parse_list_contents(tokens, list)

      :close_bracket ->
        parse_list_contents(tokens, list)
    end
  end

  defguardp int?(x) when x in [?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9] 

  defp scan([], acc), do: Enum.reverse(acc)

  defp scan([?[ | tail], acc), do: scan(tail, [:open_bracket | acc])

  defp scan([?] | tail], acc), do: scan(tail, [:close_bracket | acc])

  defp scan([?, | tail], acc), do: scan(tail, [:comma | acc])

  defp scan([?\s | tail], acc), do: scan(tail, acc)

  defp scan([char | _tail] = chars, acc) when int?(char) do
    {int, tail} = parse_integer(chars, 0)
    acc = [int | acc]
    scan(tail, acc)
  end

  defp parse_integer([char | tail], acc) when int?(char) do
    acc = acc * 10 + char - ?0
    parse_integer(tail, acc)
  end

  defp parse_integer(chars, acc), do: {acc, chars}
end

IO.puts("sum of indices for packages in order (part 1): #{Aoc2022.Day13.part1()}")
IO.puts("prod of distress signals' indices (part 2): #{Aoc2022.Day13.part2()}")

