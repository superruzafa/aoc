defmodule Aoc2023.Day10.Maze do
  defstruct [
    :map,
    :size,
    :start,
  ]

  def parse_input(input) do
    rows =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.with_index()

    height = length(rows)
    width =
      rows 
      |> List.first()
      |> case do
        {row, _} -> String.length(row)
      end

    map =
      rows
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn
          {"S", x} -> {{x, y}, :start}
          {"|", x} -> {{x, y}, "│"}
          {"-", x} -> {{x, y}, "─"}
          {"L", x} -> {{x, y}, "└"}
          {"J", x} -> {{x, y}, "┘"}
          {"7", x} -> {{x, y}, "┐"}
          {"F", x} -> {{x, y}, "┌"}
          _ -> nil
        end)
        |> Enum.reject(&is_nil/1)
      end)
      |> Map.new()

    %__MODULE__{
      map: map,
      size: {width, height},
      start: Enum.find_value(map, fn
        {xy, :start} -> xy
        _ -> false
      end)
    }
  end

  def inside_maze?(maze, {x, y}) do
    {width, height} = maze.size
    (x in 0..width - 1) and (y in 0..height - 1)
  end

  def empty_at?(%__MODULE__{} = maze, xy) do
    not Map.has_key?(maze.map, xy)
  end

  @gates %{
    "│" => [:north, :south],
    "─" => [:east, :west],
    "└" => [:north, :east],
    "┘" => [:north, :west],
    "┐" => [:south, :west],
    "┌" => [:south, :east]
  }

  def has_gate?(%__MODULE__{} = maze, xy, gate) do
    maze.map
    |> Map.get(xy)
    |> case do
      :start -> true
      nil -> false
      gate_type -> gate in @gates[gate_type]
    end
  end

  def apply_path(maze, path) do
    map =
      path
      |> Enum.reduce(%{}, fn xy, map ->
        Map.put(map, xy, maze.map[xy])
      end)

    %{maze | map: map}
  end

  def visualize(%__MODULE__{} = maze) do
    {width, height} = maze.size
    for y <- 0..height-1 do
      for x <- 0..width-1 do
        case Map.get(maze.map, {x, y}) do
          :start -> "S"
          nil -> " "
          pipe_type -> pipe_type
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
  end

  def x2(%__MODULE__{} = maze) do
    map =
      maze.map
      |> Enum.flat_map(fn {{x, y}, pipe_type} ->
        double(pipe_type)
        |> String.split("\n", trim: true)
        |> Enum.join()
        |> String.split("", trim: true)
        |> case do
          [a, b, c, d] -> [
            {{x * 2,     y * 2},     a},
            {{x * 2 + 1, y * 2},     b},
            {{x * 2,     y * 2 + 1}, c},
            {{x * 2 + 1, y * 2 + 1}, d},
          ]
          |> Enum.reject(fn {_, pipe_type} -> pipe_type == "." end)
        end
      end)
      |> Map.new()


    {sx, sy} = maze.start
    {width, height} = maze.size

    %__MODULE__{
      map: map,
      size: {width * 2, height * 2},
      start: {sx * 2, sy * 2}
    }
  end

  defp double("│") do
    """
    │.
    │.
    """
  end

  defp double("┌") do
  #defp pipe_for(:south_east), do: "┌"
    """
    ┌─
    │.
    """
  end

  defp double("└") do
    """
    └─
    ..
    """
  end

  defp double("┐") do
    """
    ┐.
    │.
    """
  end

  defp double("─") do
    """
    ──
    ..
    """
  end

  defp double("┘") do
    """
    ┘.
    ..
    """
  end

  defp double(:start) do
    """
    SS
    SS
    """
  end

end

defmodule Aoc2023.Day10 do
  alias Aoc2023.Day10.Maze

  def find_path(%Maze{} = maze) do
    do_find_path(maze, maze.start, [], MapSet.new(), 0)
  end

  @minimum_path_length 4

  defp do_find_path(%Maze{start: xy}, xy, path, _visited, pipe_length)
    when pipe_length >= @minimum_path_length
    do
      path
  end

  defp do_find_path(%Maze{} = maze, xy, path, visited, pipe_length) do
    candidates = find_candidates(maze, xy, visited)

    if Enum.empty?(candidates) do
      false
    else
      candidates
      |> Enum.find_value(fn xy_next ->
        visited = MapSet.put(visited, xy_next)
        path = [xy_next | path]
        do_find_path(maze, xy_next, path, visited, pipe_length + 1)
      end)
    end
  end

  defp find_candidates(%Maze{} = maze, {x, y} = xy, visited) do
    [
      %{exit: :east,  xy: {x + 1, y}, enter: :west},
      %{exit: :south, xy: {x, y + 1}, enter: :north},
      %{exit: :west,  xy: {x - 1, y}, enter: :east},
      %{exit: :north, xy: {x, y - 1}, enter: :south},
    ]
    |> Enum.filter(fn move -> Maze.inside_maze?(maze, move.xy) end)
    |> Enum.reject(fn move -> move.xy in visited end)
    |> Enum.filter(fn move -> Maze.has_gate?(maze, xy, move.exit) end)
    |> Enum.filter(fn move -> Maze.has_gate?(maze, move.xy, move.enter) end)
    |> Enum.map(fn move -> move.xy end)
  end
end

defmodule Aoc2023.Day10.Part1 do
  import Aoc2023.Day10.Maze
  import Aoc2023.Day10

  def run(input) do
    input
    |> parse_input()
    |> find_path()
    |> length()
    |> div(2)
  end

end

defmodule Aoc2023.Day10.Part2 do
  alias Aoc2023.Day10.Maze
  import Aoc2023.Day10.Maze
  import Aoc2023.Day10

  def run(input) do
    maze = parse_input(input)
    path = find_path(maze)

    maze =
      maze
      |> apply_path(path)
      |> x2()

    maze
    |> paint(maze.start)
    |> count_2x_tiles()
  end

  defp paint(maze, xy) do
    map = Map.put(maze.map, xy, "I")
    maze = %{maze | map: map}

    maze
    |> Map.put(:map, map)
    |> generate_neighbours(xy)
    |> Enum.reduce(maze, fn xy_fill, maze_fill ->
      paint(maze_fill, xy_fill)
    end)
  end

  defp generate_neighbours(maze, {x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.filter(& Maze.inside_maze?(maze, &1))
    |> Enum.filter(& Maze.empty_at?(maze, &1))
  end

  defp count_2x_tiles(%Maze{} = maze) do
    {width, height} = maze.size

    for y <- 0..height-1//2,
      x <- 0..width-1//2 do
        {x, y}
    end
    |> Enum.count(fn {x, y} ->
      [
        {x, y},
        {x + 1, y},
        {x, y + 1},
        {x + 1, y + 1}
      ]
      |> Enum.all?(fn xy -> Map.get(maze.map, xy) == "I" end)
    end)
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day10.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day10.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end


