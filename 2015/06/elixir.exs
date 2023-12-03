defmodule Aoc2015.Day6.Grid do
  defstruct [
    :grid
  ]

  def new do
    %__MODULE__{
      grid: %{}
    }
  end

  def execute_bool(grid, command, xy) do
    status = Map.get(grid.grid, xy, false)

    case command do
      :turn_on -> %{grid | grid: Map.put(grid.grid, xy, true)}
      :turn_off -> %{grid | grid: Map.put(grid.grid, xy, false)}
      :toggle -> %{grid | grid: Map.put(grid.grid, xy, not status)}
    end
  end

  def execute_bright(grid, command, xy) do
    case command do
      :turn_on -> %{grid | grid: Map.update(grid.grid, xy, 1, & &1 + 1)}
      :turn_off -> %{grid | grid: Map.update(grid.grid, xy, 0, & max(0, &1 - 1))}
      :toggle -> %{grid | grid: Map.update(grid.grid, xy, 2, & &1 + 2)}
    end
  end

  def count_bool(grid),
    do: Enum.count(grid.grid, fn {_, status} -> status end)

  def count_bright(grid) do
    grid.grid
    |> Enum.map(fn {_, bright} -> bright end)
    |> Enum.sum()
  end

end

defmodule Aoc2015.Day6 do
  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  defp parse_instruction(line) do
    matches = Regex.named_captures(~r/(?<command>turn off|turn on|toggle) (?<xy0>\d+,\d+) through (?<xy1>\d+,\d+)/, line)
    {
      parse_command(matches["command"]),
      parse_coordinate(matches["xy0"]),
      parse_coordinate(matches["xy1"])
    }
  end

  defp parse_command("turn off"), do: :turn_off
  defp parse_command("turn on"), do: :turn_on
  defp parse_command("toggle"), do: :toggle

  defp parse_coordinate(coordinate) do
    [x, y] = String.split(coordinate, ",")
    {x, _} = Integer.parse(x)
    {y, _} = Integer.parse(y)
    {x, y}
  end

  def generate_points({x0, y0}, {x1, y1}) do
    for y <- y0..y1, x <- x0..x1, do: {x, y}
  end

end

defmodule Aoc2015.Day6.Part1 do
  import Aoc2015.Day6
  alias Aoc2015.Day6.Grid

  import Aoc2015.Day6

  def run(input) do
    grid = Grid.new()

    grid =
      input
      |> parse_input()
      |> Enum.reduce(grid, & execute_instruction(&2, &1))

    Grid.count_bool(grid)
  end

  defp execute_instruction(%Grid{} = grid, inst) do
    {command, xy0, xy1} = inst

    generate_points(xy0, xy1)
    |> Enum.reduce(grid, & Grid.execute_bool(&2, command, &1))
  end

end

defmodule Aoc2015.Day6.Part2 do
  alias Aoc2015.Day6.Grid
  import Aoc2015.Day6

  def run(input) do
    grid = Grid.new()

    grid =
      input
      |> parse_input()
      |> Enum.reduce(grid, & execute_instruction(&2, &1))

    Grid.count_bright(grid)
  end

  defp execute_instruction(%Grid{} = grid, inst) do
    {command, xy0, xy1} = inst

    generate_points(xy0, xy1)
    |> Enum.reduce(grid, & Grid.execute_bright(&2, command, &1))
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2015.Day6.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2015.Day6.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

