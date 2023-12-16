defmodule Aoc2023.Day16.Contraption do
  defstruct [
    tiles: %{},
    width: 0,
    height: 0
  ]

  def parse(input) do
    lines =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    width = lines |> hd() |> String.length()
    height = length(lines)

    tiles =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.flat_map(fn
          {".", _x} -> []
          {v, x} -> [{{x, y}, v}]
        end)
      end)
      |> Map.new()

    %__MODULE__{
      tiles: tiles,
      width: width,
      height: height
    }
  end

  def at(%__MODULE__{} = contraption, {x, y} = xy) do
    %{tiles: tiles, width: width, height: height} = contraption

    cond do
      x < 0 or x >= width -> nil
      y < 0 or y >= height -> nil
      true -> Map.get(tiles, xy, ".")
    end
  end

end

defmodule Aoc2023.Day16 do
  alias Aoc2023.Day16.Contraption

  def count_energized(%Contraption{} = contraption, xy, direction) do
    contraption
    |> traverse(xy, direction, MapSet.new())
    |> Enum.map(fn {xy, _dir} -> xy end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def draw(%Contraption{} = contraption, energized) do
    energized = energized
      |> Enum.map(fn {xy, _dir} -> xy end)
      |> MapSet.new()

    for y <- 0..contraption.height - 1 do
      for x <- 0..contraption.width - 1 do
        cond do
          MapSet.member?(energized, {x, y}) -> IO.write("#")
          true -> IO.write(".")
        end
      end
      IO.puts("")
    end
  end

  defp traverse(%Contraption{} = contraption, xy, direction, energized) do
    if MapSet.member?(energized, {xy, direction}),
      do: energized,
      else: do_traverse(contraption, xy, direction, energized)
  end

  defp do_traverse(%Contraption{} = contraption, xy, direction, energized) do
    case {Contraption.at(contraption, xy), direction} do
      {nil, _} ->
        energized

      {".", dir} ->
        energized = MapSet.put(energized, {xy, dir})
        traverse(contraption, move(xy, dir), dir, energized)

      {"|", dir} when dir in [:up, :down] ->
        energized = MapSet.put(energized, {xy, dir})
        traverse(contraption, move(xy, dir), dir, energized)

      {"-", dir} when dir in [:left, :right] ->
        energized = MapSet.put(energized, {xy, dir})
        traverse(contraption, move(xy, dir), dir, energized)

      {"|", dir} when dir in [:left, :right] ->
        energized = MapSet.put(energized, {xy, dir})
        energized = traverse(contraption, move(xy, :up), :up, energized)
        traverse(contraption, move(xy, :down), :down, energized)

      {"-", dir} when dir in [:down, :up] ->
        energized = MapSet.put(energized, {xy, dir})
        energized = traverse(contraption, move(xy, :right), :right, energized)
        traverse(contraption, move(xy, :left), :left, energized)

      {mirror, dir} when mirror in ["/", "\\"] ->
        energized = MapSet.put(energized, {xy, dir})
        dir = turn(mirror, dir)
        traverse(contraption, move(xy, dir), dir, energized)

    end
  end

  defp move({x, y}, :right), do: {x + 1, y}
  defp move({x, y}, :left), do: {x - 1, y}
  defp move({x, y}, :up), do: {x, y - 1}
  defp move({x, y}, :down), do: {x, y + 1}

  defp turn("\\", :left), do: :up
  defp turn("\\", :right), do: :down
  defp turn("\\", :up), do: :left
  defp turn("\\", :down), do: :right

  defp turn("/", :left), do: :down
  defp turn("/", :right), do: :up
  defp turn("/", :up), do: :right
  defp turn("/", :down), do: :left
  
end

defmodule Aoc2023.Day16.Part1 do
  alias Aoc2023.Day16.Contraption

  import Aoc2023.Day16

  def run(input) do
    input
    |> Contraption.parse()
    |> count_energized({0, 0}, :right)
  end

end

defmodule Aoc2023.Day16.Part2 do
  alias Aoc2023.Day16.Contraption

  import Aoc2023.Day16

  def run(input) do
    contraption = Contraption.parse(input)

    enter1 = for x <- 0..contraption.width - 1, do: [{{x, 0}, :down}, {{x, contraption.height - 1}, :up}]
    enter2 = for y <- 0..contraption.height - 1, do: [{{0, y}, :right}, {{contraption.width - 1, y}, :left}]

    List.flatten(enter1 ++ enter2)
    |> Enum.reduce(0, fn {xy, dir}, maximum ->
      max(maximum, count_energized(contraption, xy, dir))
    end)

  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day16.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day16.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

