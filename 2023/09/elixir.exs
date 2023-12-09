defmodule Aoc2023.Day9 do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&as_integer/1)
    end)
  end

  defp as_integer(string) do
    {int, _} = Integer.parse(string)
    int
  end

  def extrapolate(history, differences \\ [])

  def extrapolate([v1, v2], differences) do
    differences = [v2 - v1 | differences]
    if all_zeros?(differences) do
      v2
    else
      delta = differences
              |> Enum.reverse()
              |> extrapolate()
      v2 + delta
    end
  end

  def extrapolate([v1, v2 | tail], differences) do
    differences = [v2 - v1 | differences]
    extrapolate([v2 | tail], differences)
  end

  defp all_zeros?(differences),
    do: Enum.all?(differences, & &1 == 0)

end

defmodule Aoc2023.Day9.Part1 do
  import Aoc2023.Day9

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&extrapolate/1)
    |> Enum.sum()
  end

end

defmodule Aoc2023.Day9.Part2 do
  import Aoc2023.Day9

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&extrapolate/1)
    |> Enum.sum()
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day9.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day9.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end


