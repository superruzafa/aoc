#!/usr/bin/env elixir
defmodule Aoc2022.Day20 do

  def part1 do
    numbers = load()
    numbers = Enum.with_index(numbers, 1)
    numbers_length = length(numbers)

    numbers =
      1..numbers_length
      |> Enum.reduce(numbers, fn number_index, numbers ->
        show(numbers)
        run(numbers, numbers_length, number_index)
      end)
    show(numbers)


    zero_position= Enum.find_index(numbers, fn {n, _pos} -> n == 0 end)

    [1000, 2000, 3000]
    |> Enum.map(&rem(zero_position + &1, numbers_length))
    |> Enum.map(&Enum.at(numbers, &1))
    |> Enum.map(fn {n, _pos} -> n end)
    |> Enum.sum()
  end
  

  if false do
  """
  Initial arrangement:
1, 2, -3, 3, -2, 0, 4

1 moves between 2 and -3:
2, 1, -3, 3, -2, 0, 4

2 moves between -3 and 3:
1, -3, 2, 3, -2, 0, 4

-3 moves between -2 and 0:
1, 2, 3, -2, -3, 0, 4

3 moves between 0 and 4:
1, 2, -2, -3, 0, 3, 4

-2 moves between 4 and 1:
1, 2, -3, 0, 3, 4, -2

0 does not move:
1, 2, -3, 0, 3, 4, -2

4 moves between -3 and 0:
1, 2, -3, 4, 0, 3, -2
"""

  end

  defp show(numbers) do
    numbers
    |> Enum.map(fn {n, _ni} -> n end)
    |> IO.inspect()

    numbers
  end

  #defp run(numbers, numbers_length, index) when numbers_length == index, do: numbers
  #
  defp modulo(number, modulo), do:
    rem(rem(number, modulo) + modulo, modulo)

  defp run(numbers, numbers_length, number_index) do
    find_take(numbers, number_index)
    |> case do

      {{number, _number_index} = elem, numbers, position} ->
        remainder = rem(number + position, numbers_length)
        position =
          cond do
            remainder == 0 -> -1
            remainder < 0 -> remainder - 1
            number + position > numbers_length -> remainder + 1
            true -> remainder
          end
        List.insert_at(numbers, position, elem)
    end
  end

  defp find_take(numbers, number_index), do:
    do_find_take(numbers, number_index, 0, []) 

  defp do_find_take([], _number_index, _position, _heads), do: nil

  defp do_find_take([{_number, number_index} = head | tail], number_index, position, heads) do
   numbers = Enum.reverse(heads) ++ tail 
   {head, numbers, position}
  end

  defp do_find_take([head | tail], number_index, position, heads), do:
    do_find_take(tail, number_index, position + 1, [head | heads])

  def load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

end

IO.puts("surface area (part 1): #{Aoc2022.Day20.part1()}")
#IO.puts("exterior surface area (part 2): #{Aoc2022.Day20.part2()}")

