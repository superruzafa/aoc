defmodule Aoc2023.Day13.Pattern do
  defstruct [
    width: 0,
    height: 0,
    cells: %{}
  ]

  def parse(line) do
    rows =
      line
      |> String.split("\n", trim: true)

    cells =
      rows
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn
          {v, x} -> {{x, y}, v}
        end)
      end)
      |> Map.new()
;
    width = rows |> hd() |> String.length()
    height = length(rows)

    %__MODULE__{
      width: width,
      height: height,
      cells: cells
    }
  end

  def swap(%__MODULE__{} = pattern, xy) do
    cells =
      pattern.cells
      |> Map.update!(xy, fn
        "#" -> "."
        "." -> "#"
      end)
    %{pattern | cells: cells}
  end

  def draw(%__MODULE__{} = pattern) do
    for y <- 0..pattern.height - 1 do
      for x <- 0..pattern.width - 1 do
        IO.write(Map.fetch!(pattern.cells, {x, y}))
      end
      IO.puts("")
    end
    IO.puts("")
    pattern
  end

  def split_horizontally(%__MODULE__{} = pattern, row, symmetry_axis) do
    {
      extract_left(pattern, row, symmetry_axis),
      extract_right(pattern, row, symmetry_axis)
    }
  end

  def split_vertically(%__MODULE__{} = pattern, col, row) do
    {
      extract_above(pattern, row, col),
      extract_below(pattern, row, col)
    }
  end

  defp extract_left(%__MODULE__{} = pattern, row, symmetry_axis) do
    0..symmetry_axis - 1
    |> Enum.map(fn x -> Map.fetch!(pattern.cells, {x, row}) end)
    |> Enum.join()
  end

  defp extract_right(%__MODULE__{} = pattern, row, symmetry_axis) do
    symmetry_axis..pattern.width - 1
    |> Enum.map(fn x -> Map.fetch!(pattern.cells, {x, row}) end)
    |> Enum.join()
  end

  defp extract_above(%__MODULE__{} = pattern, row, col) do
    0..row - 1
    |> Enum.map(fn y -> Map.fetch!(pattern.cells, {col, y}) end)
    |> Enum.join()
  end

  defp extract_below(%__MODULE__{} = pattern, row, col) do
    row..pattern.height - 1
    |> Enum.map(fn y -> Map.fetch!(pattern.cells, {col, y}) end)
    |> Enum.join()
  end
end

defmodule Aoc2023.Day13 do
  alias Aoc2023.Day13.Pattern

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(&Pattern.parse/1)
  end

  def find_reflection(%Pattern{} = pattern) do
    ver_axes = pattern 
               |> find_vertical_symmetry_axes() 
               |> MapSet.to_list()

    hor_axes = pattern 
               |> find_horizontal_symmetry_axes() 
               |> MapSet.to_list

    case {ver_axes, hor_axes} do
      {[ver_axes], []} -> ver_axes
      {[], [hor_axes]} -> hor_axes * 100
    end
  end

  def find_reflection_with_smudge(pattern) do
    old_ver_axes = find_vertical_symmetry_axes(pattern)
    old_hor_axes = find_horizontal_symmetry_axes(pattern)

    0..pattern.height - 1
    |> Enum.find_value(fn row ->
      0..pattern.width - 1
      |> Enum.find_value(fn col ->
        pattern = Pattern.swap(pattern, {col, row})

        ver_axes = pattern 
               |> find_vertical_symmetry_axes() 
               |> MapSet.difference(old_ver_axes) 
               |> MapSet.to_list()

        hor_axes = pattern 
               |> find_horizontal_symmetry_axes() 
               |> MapSet.difference(old_hor_axes) 
               |> MapSet.to_list()

        case {ver_axes, hor_axes} do
          {[], []} -> false
          {[ver_axis], []} -> ver_axis
          {[], [hor_axis]} -> hor_axis * 100
        end

      end)
    end)

  end

  defp find_vertical_symmetry_axes(pattern) do
    1..pattern.width - 1
    |> Enum.filter(fn symmetry_axis ->
      0..pattern.height - 1
      |> Enum.all?(fn y ->
        reflected_horizontally?(pattern, y, symmetry_axis)
      end)
    end)
    |> MapSet.new()
  end

  defp find_horizontal_symmetry_axes(pattern) do
    1..pattern.height - 1
    |> Enum.filter(fn symmetry_axis ->
      0..pattern.width - 1
      |> Enum.all?(fn x ->
        reflected_vertically?(pattern, x, symmetry_axis)
      end)
    end)
    |> MapSet.new()
  end

  defp reflected_horizontally?(pattern, row, symmetry_axis) do
    {left, right} = Pattern.split_horizontally(pattern, row, symmetry_axis)
    symmetric?(left, right)
  end

  defp reflected_vertically?(pattern, col, symmetry_axis) do
    {above, below} = Pattern.split_vertically(pattern, col, symmetry_axis)
    symmetric?(above, below)
  end

  defp symmetric?(string, reflection) do
    min_length = min(String.length(string), String.length(reflection))
    string = String.slice(string, -min_length, min_length)
    reflection = reflection |> String.slice(0, min_length) |> String.reverse()
    string == reflection
  end

end

defmodule Aoc2023.Day13.Part1 do
  import Aoc2023.Day13

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&find_reflection/1)
    |> Enum.sum()
  end

end

defmodule Aoc2023.Day13.Part2 do
  import Aoc2023.Day13
  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&find_reflection_with_smudge/1)
    |> Enum.sum()
  end
end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day13.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day13.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end


