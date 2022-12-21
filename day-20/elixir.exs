#!/usr/bin/env elixir
defmodule Aoc2022.Day20 do

  def part1 do


    list = load()
           |> add_order()

    list_length = length(list)

    0..list_length - 1
    |> Enum.reduce(list, &mix(&2, list_length, &1))
    |> remove_order()
    |> get_coords(list_length)
  end

  @decryption_key 811589153

  def part2 do
    list =
      load()
      |> Enum.map(& &1 * @decryption_key)
      |> add_order()

    list_length = length(list)

    1..10
    |> Enum.reduce(list, fn _, list ->
      0..list_length - 1
      |> Enum.reduce(list, &mix(&2, list_length, &1))
    end)
    |> remove_order()
    |> get_coords(list_length)
  end

  def tests do
    [
      {[0, 2, -3, 0, 2, 1, -2], 0, [0, 2, -3, 0, 2, 1, -2]},
      {[2, 2, -3, 0, 2, 1, -2], 0, [2, -3, 2, 0, 2, 1, -2]},
      {[7, 2, -3, 0, 2, 1, -2], 0, [2, 7, -3, 0, 2, 1, -2]},
      {[8, 2, -3, 0, 2, 1, -2], 0, [2, -3, 8, 0, 2, 1, -2]},
      {[6, 2, -3, 0, 2, 1, -2], 0, [6, 2, -3, 0, 2, 1, -2]},
      {[5, 2, -3, 0, 2, 1, -2], 0, [2, -3, 0, 2, 1, 5, -2]},
      {[12, 2, -3, 0, 2, 1, -2], 0, [12, 2, -3, 0, 2, 1, -2]},
      {[12, 2, -3, 0, 2, 1, -2], 5, [1, 12, 2, -3, 0, 2, -2]},
      {[12, 2, -3, 0, 2, 1, 1], 6, [12, 1, 2, -3, 0, 2, 1]},
      {[13, 2, -3, 0, 2, 1, -2], 0, [2, 13, -3, 0, 2, 1, -2]},
      {[23, 2, -3, 0, 2, 1, -2], 0, [2, -3, 0, 2, 1, 23, -2]},
      {[24, 2, -3, 0, 2, 1, -2], 0, [24, 2, -3, 0, 2, 1, -2]},
      {[24, 2, -1, 0, 2, 1, -2], 2, [24, -1, 2, 0, 2, 1, -2]},
      {[24, 2, -2, 0, 2, 1, -5], 2, [24, 2, 0, 2, 1, -5, -2]},
      {[24, 2, -3, 0, 2, 1, -5], 2, [24, 2, 0, 2, 1, -3, -5]},
    ]
    |> Enum.each(fn {curr, order, expected} ->
      actual = curr |> add_order() |> mix(length(curr), order) |> remove_order()
      if actual != expected do
        IO.inspect(curr)
        IO.inspect(order)
        IO.inspect(expected)
        IO.inspect(actual)
        raise "boom"
      end
    end)
  end

  defp get_coords(list, list_length) do
    index = Enum.find_index(list, &Kernel.==(&1, 0))

    [1000, 2000, 3000]
    |> Enum.map(& rem(index + &1, list_length))
    |> Enum.map(&Enum.at(list, &1))
    |> Enum.sum()
  end

  defp add_order(list) do
    Enum.with_index(list)
  end

  defp remove_order(list) do
    Enum.map(list, &elem(&1, 0))
  end

  defp mix(list, list_length, order) do
    {{number, _order} = elem, pos , temp_list} = take_by_order(list, order)

    new_pos = rem(pos + number, list_length - 1)

    do_mix(%{
      list: list,
      list_length: list_length,
      elem: elem,
      temp_list: temp_list,
      number: number,
      pos: pos,
      new_pos: new_pos
    })
  end

  defp do_mix(params) when params.number < 0 and params.new_pos == 0 do
    List.insert_at(params.temp_list, -1, params.elem)
  end

  defp do_mix(params) when params.number < 0 and params.new_pos < 0 do
    List.insert_at(params.temp_list, params.new_pos - 1, params.elem)
  end

  defp do_mix(params) when params.new_pos < params.pos do
    List.insert_at(params.temp_list, params.new_pos, params.elem)
  end

  defp do_mix(params) when params.number > 0 do
    new_pos = rem(params.number + params.pos, params.list_length - 1)
    List.insert_at(params.temp_list, new_pos, params.elem)
  end

  defp do_mix(params) do
    List.insert_at(params.temp_list, params.new_pos, params.elem)
  end

  defp take_by_order(list, order) do
    do_take_by_order(list, [], 0, order)
  end

  defp do_take_by_order([{_, order} = head | tail], heads, position, order) do
    {head, position, Enum.reverse(heads) ++ tail}
  end

  defp do_take_by_order([head | tail], heads, position, order) do
    do_take_by_order(tail, [head | heads], position + 1, order)
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

end

IO.puts("sum of the three grove coordinates (part 1): #{Aoc2022.Day20.part1()}")
IO.puts("sum of the three grove coordinates (part 2): #{Aoc2022.Day20.part2()}")

