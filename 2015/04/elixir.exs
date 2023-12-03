defmodule Aoc2015.Day4 do
  def find_hash(key, prefix, number \\ 0) do
    input = "#{key}#{number}"
    hash = :md5 |> :crypto.hash(input) |> Base.encode16()

    if String.starts_with?(hash, prefix),
      do: number,
      else: find_hash(key, prefix, number + 1)

  end
end

defmodule Aoc2015.Day4.Part1 do

  def run(input) do
    Aoc2015.Day4.find_hash(input, "00000")
  end

end

defmodule Aoc2015.Day4.Part2 do

  def run(input) do
    Aoc2015.Day4.find_hash(input, "000000")
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day4.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day4.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

