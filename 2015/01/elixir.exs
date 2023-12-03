defmodule Aoc2015.Day1.Part1 do

  def run(input) do
    input
    |> File.read!()
    |> String.to_charlist()
    |> Enum.reduce(0, fn
      ?(, floor -> floor + 1
      ?), floor -> floor - 1
      _, floor -> floor
    end)
  end

end

defmodule Aoc2015.Day1.Part2 do

  def run(input) do
    input
    |> File.read!()
    |> String.to_charlist()
    |> Enum.with_index(1)
    |> Enum.reduce_while(0, fn
      {?(, _pos}, floor -> {:cont, floor + 1}
      {?), pos}, 0 -> {:halt, pos}
      {?), _pos}, floor -> {:cont, floor - 1}
    end)
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day1.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day1.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

