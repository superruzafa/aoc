defmodule Aoc2015.Day5.State do
  defstruct [
    prev: nil,
    double: false,
    forbidden: false,
    vowels: 0
  ]

  def new do
    %__MODULE__{}
  end
end


defmodule Aoc2015.Day5 do
  alias Aoc2015.Day5.State

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def vowel?(char), do: char in ~c"aeiou"

  def forbidden?(prev, curr) do
    seq = List.to_string([prev, curr])
    seq in ~w(ab cd pq xy)
  end

end

defmodule Aoc2015.Day5.Part1 do
  alias Aoc2015.Day5.State

  import Aoc2015.Day5

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(& String.to_charlist/1)
    |> Enum.filter(& nice?(&1, State.new()))
    |> Enum.count()
  end

  defp nice?([], state) do
    not state.forbidden and
      state.vowels >= 3 and
      state.double
  end

  defp nice?([head | tail], state) do
    state =
      if vowel?(head),
        do: %{state | vowels: state.vowels + 1},
        else: state

    state =
      if is_nil(state.prev),
        do: state,
        else: %{state | double: state.double or state.prev == head}

    state =
      if is_nil(state.prev),
        do: state,
        else: %{state | forbidden: state.forbidden or forbidden?(state.prev, head)}

    state = %{state | prev: head}
    nice?(tail, state)

  end

end

defmodule Aoc2015.Day5.Part2 do
  import Aoc2015.Day5

  def run(input) do
    input
    |> parse_input()
    |> Enum.filter(&nice?/1)
    |> Enum.count()
  end

  defp nice?(string) do
    chars = String.to_charlist(string)
    rule_1(chars) and rule_2(chars)
  end

  defp rule_1(list) when length(list) <= 1, do: false

  defp rule_1([a, b | rest]) do
    appears_twice?([a, b], rest) or rule_1([b | rest])
  end

  defp appears_twice?([a, b], list) when length(list) <= 1, do: false
  defp appears_twice?([a, b], [a, b | rest]), do: true
  defp appears_twice?([a, b], [_ | rest]), do: appears_twice?([a, b], rest)

  defp rule_2(list) when length(list) <= 2, do: false
  defp rule_2([a, b, a | rest]), do: true
  defp rule_2([_, b, c | rest]), do: rule_2([b, c | rest])

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day5.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day5.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

