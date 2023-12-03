defmodule Aoc2023.Day2.Set do
  defstruct [
    red: 0,
    green: 0,
    blue: 0
  ]

  def parse(set_line) do
    set_line
    |> String.split(",")
    |> Enum.reduce(%__MODULE__{}, fn cube, set ->
      matches = Regex.named_captures(~r/(?<count>\d+) (?<color>\w+)/, cube)
      {count, _} = Integer.parse(matches["count"])
      color = String.to_atom(matches["color"])
      Map.put(set, color, count)
    end)
  end
end

defmodule Aoc2023.Day2.Game do
  alias Aoc2023.Day2.Set

  defstruct [
    :id,
    :sets
  ]

  def parse(game_line) do
    [game, sets] = String.split(game_line, ":")
    matches = Regex.named_captures(~r/Game (?<id>\d+)/, game)

    {id, _} = Integer.parse(matches["id"])
    sets =
      sets
      |> String.split(";", trim: true)
      |> Enum.map(&Set.parse/1)

    %__MODULE__{
      id: id ,
      sets: sets
    }
  end
end

defmodule Aoc2023.Day2 do
  alias Aoc2023.Day2.Game

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&Game.parse/1)
  end
end

defmodule Aoc2023.Day2.Part1 do
  alias Aoc2023.Day2
  alias Aoc2023.Day2.Game
  alias Aoc2023.Day2.Set

  def run(input) do
    input
    |> Day2.parse_input()
    |> Enum.filter(&possible_game?/1)
    |> Enum.map(& &1.id)
    |> Enum.sum()
  end

  defp possible_game?(%Game{} = game) do
    Enum.all?(game.sets, &possible_set?/1)
  end

  @minimum_required_red 12
  @minimum_required_green 13
  @minimum_required_blue 14

  defp possible_set?(%Set{} = set) do
    set.red <= @minimum_required_red and
      set.green <= @minimum_required_green and
      set.blue <= @minimum_required_blue
  end

end

defmodule Aoc2023.Day2.Part2 do
  alias Aoc2023.Day2
  alias Aoc2023.Day2.Game
  alias Aoc2023.Day2.Set

  def run(input) do
    input
    |> Day2.parse_input()
    |> Enum.map(&game_minimum_set/1)
    |> Enum.map(&set_power/1)
    |> Enum.sum()
  end

  defp game_minimum_set(%Game{} = game) do
    Enum.reduce(game.sets, %Set{}, fn set, min_set ->
      %{min_set |
        red: max(set.red, min_set.red),
        green: max(set.green, min_set.green),
        blue: max(set.blue, min_set.blue)
      }
    end)
  end

  defp set_power(%Set{} = set),
    do: set.red * set.green * set.blue

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day2.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day2.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

