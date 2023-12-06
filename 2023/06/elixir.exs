defmodule Aoc2023.Day6 do
  def parse_input_part_1(input) do
    [times, distances] =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    times = parse_values_part_1(times)
    distances = parse_values_part_1(distances)

    Enum.zip(times, distances)
  end

  defp parse_values_part_1(line) do
    [_label, values] = String.split(line, ":")
    values
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&as_integer/1)
  end

  def parse_input_part_2(input) do
    [times, distances] =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    times = parse_values_part_2(times)
    distances = parse_values_part_2(distances)

    {times, distances}
  end

  defp parse_values_part_2(line) do
    [_label, values] = String.split(line, ":")
    values
    |> String.split(~r/\s+/, trim: true)
    |> Enum.join("")
    |> as_integer()
  end

  defp as_integer(value) do
    {int, _} = Integer.parse(value)
    int
  end

  def winning_races({time, record_distance}) do
    1..time - 1
    |> Enum.count(fn time_button_pressed ->
      distance = time_button_pressed * (time - time_button_pressed)
      distance > record_distance
    end)
  end

end

defmodule Aoc2023.Day6.Part1 do
  import Aoc2023.Day6

  def run(input) do
    input
    |> parse_input_part_1()
    |> Enum.map(&winning_races/1)
    |> Enum.product()
  end

end

defmodule Aoc2023.Day6.Part2 do
  import Aoc2023.Day6

  def run(input) do
    input
    |> parse_input_part_2()
    |> winning_races()
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day6.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day6.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

