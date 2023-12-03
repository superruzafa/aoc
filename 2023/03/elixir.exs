defmodule Aoc2023.Day3.EngineSchema do
  defstruct [
    map: %{},
    width: 0,
    height: 0
  ]

  def parse(input) do
    rows =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.with_index()

    map =
      rows
      |> Enum.flat_map(fn {row, y} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {xy, x} -> {{x, y}, xy} end)
      end)
      |> Map.new()

    {width, height} = Enum.reduce(map, {0, 0}, fn
      {{x, y}, _}, {width, height} ->
        {max(x, width), max(y, height)}
    end)

    %__MODULE__{
      map: map,
      width: width + 1,
      height: height + 1
    }

  end

end

defmodule Aoc2023.Day3.Number do
  defstruct [
    number: 0,
    xy: {0, 0},
    len: 1
  ]
end

defmodule Aoc2023.Day3 do
  alias Aoc2023.Day3.Number
  alias Aoc2023.Day3.EngineSchema

  defp digit?(%EngineSchema{} = schema, xy) do
    if Map.has_key?(schema.map, xy),
      do: schema.map[xy] in ~w(0 1 2 3 4 5 6 7 8 9),
      else: false
  end

  defp symbol?(%EngineSchema{} = schema, xy) do
    if Map.has_key?(schema.map, xy),
      do: schema.map[xy] not in ~w(0 1 2 3 4 5 6 7 8 9 .),
      else: false
  end

  @doc """
  Returns a list with all numbers found in the EngineSchema `schema`
  starting at the position `xy`, going from left to right and top to down.

  The list's elements has like this: {number, xy, len}, where:
    - `number` is the integer itself
    - `xy` is the point where it was found
    - `len` denotes how much digits this number has
  """

  def find_numbers(%EngineSchema{} = schema, {x, y} = xy \\ {0, 0}, findings \\ []) do
    cond do
      x >= schema.width ->
        find_numbers(schema, {0, y + 1}, findings)

      y >= schema.height ->
        findings

      digit?(schema, xy) ->
        {finding, next_point} = extract_number(schema, xy)
        find_numbers(schema, next_point, [finding | findings])

      true ->
        find_numbers(schema, {x + 1, y}, findings)
    end
  end

  defp extract_number(%EngineSchema{} = schema, {x, y} = xy, number \\ []) do
    cond do
      x == schema.width or not digit?(schema, xy) ->
        num_len = length(number)

        {number, _} =
          number
          |> Enum.reverse()
          |> Enum.join()
          |> Integer.parse()

        finding = %Number{number: number, xy: {x - num_len, y}, len: num_len}
        next_point = {x, y}

        {finding, next_point}

      true ->
        extract_number(schema, {x + 1, y}, [schema.map[xy] | number])
    end
  end

  @doc """
  Checks if a finding has a symbol around.
  """

  def symbol_around?(%EngineSchema{} = schema, finding) do
    points = points_around_number(finding.xy, finding.len)
    Enum.any?(points, & symbol?(schema, &1))
  end

  @doc """
  Generates all points around the `length` next points starting at `xy`.
  """

  def points_around_number({x, y} = _xy, num_len) do
    for py <- (y - 1)..(y + 1),
        px <- (x - 1)..(x + num_len),
        do: {px, py}
  end
end

defmodule Aoc2023.Day3.Part1 do
  alias Aoc2023.Day3
  alias Aoc2023.Day3.EngineSchema

  def run(input) do
    schema = EngineSchema.parse(input)

    schema
    |> Day3.find_numbers()
    |> Enum.filter(& Day3.symbol_around?(schema, &1))
    |> Enum.map(& &1.number)
    |> Enum.sum()
  end

end

defmodule Aoc2023.Day3.Part2 do
  alias Aoc2023.Day3
  alias Aoc2023.Day3.EngineSchema

  def run(input) do
    schema = EngineSchema.parse(input)
    findings = Day3.find_numbers(schema)
    gears = find_gears(schema)

    gears
    |> Enum.map(& find_adjacent_numbers(&1, findings))
    |> Enum.filter(& length(&1) == 2)
    |> Enum.map(fn [p1, p2] -> p1 * p2 end)
    |> Enum.sum()
  end

  defp find_gears(%EngineSchema{} = schema) do
    for y <- 0..(schema.height - 1),
      x <- 0..(schema.width - 1),
      schema.map[{x, y}] == "*",
        do: {x, y}
  end

  defp find_adjacent_numbers(gear_xy, findings) do
    findings
    |> Enum.filter(fn finding ->
       gear_xy in Day3.points_around_number(finding.xy, finding.len)
    end)
    |> Enum.map(& &1.number)
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day3.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day3.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

