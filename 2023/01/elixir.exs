defmodule Aoc2023.Day1.Part1 do

  def run(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&first_last_digits/1)
    |> Enum.sum()
  end

  defp first_last_digits(line) do
    line
    |> String.split("", trim: true)
    |> Enum.reduce({nil, nil}, fn char, acc ->
      case {as_digit(char), acc} do
        {nil, acc} -> acc
        {digit, {nil, nil}} -> {digit, digit}
        {digit, {first, _last}} -> {first, digit}
      end
    end)
    |> case do
      {_, nil} -> []
      {first, last} -> [first * 10 + last]
    end
  end

  @digits ~w(0 1 2 3 4 5 6 7 8 9)

  defp as_digit(c) do
    case c do
      c when c in @digits -> String.to_integer(c)
      _otherwise -> nil
    end
  end

end

defmodule Aoc2023.Day1.Part2 do
  def run(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_tokens/1)
    |> Enum.sum()
  end

  defp parse_tokens(line) do
    line
    |> do_parse_tokens([])
    |> first_last_digits()
  end

  defp first_last_digits([first]), do: first * 10 + first
  defp first_last_digits([first, last]), do: first * 10 + last
  defp first_last_digits([first, _next | tail]), do: first_last_digits([first | tail])

  defp do_parse_tokens("", tokens), do: Enum.reverse(tokens)

  defp do_parse_tokens(line, tokens) do
    tokens =
      case line do
        "0" <> _tail -> [0 | tokens]
        "1" <> _tail -> [1 | tokens]
        "2" <> _tail -> [2 | tokens]
        "3" <> _tail -> [3 | tokens]
        "4" <> _tail -> [4 | tokens]
        "5" <> _tail -> [5 | tokens]
        "6" <> _tail -> [6 | tokens]
        "7" <> _tail -> [7 | tokens]
        "8" <> _tail -> [8 | tokens]
        "9" <> _tail -> [9 | tokens]
        "one" <> _tail -> [1 | tokens]
        "two" <> _tail -> [2 | tokens]
        "three" <> _tail -> [3 | tokens]
        "four" <> _tail -> [4 | tokens]
        "five" <> _tail -> [5 | tokens]
        "six" <> _tail -> [6 | tokens]
        "seven" <> _tail -> [7 | tokens]
        "eight" <> _tail -> [8 | tokens]
        "nine" <> _tail -> [9 | tokens]
        _otherwise -> tokens
      end
    {_head, tail} = String.split_at(line, 1)
    do_parse_tokens(tail, tokens)
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day1.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day1.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

