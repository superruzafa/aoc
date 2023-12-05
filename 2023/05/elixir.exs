defmodule Aoc2023.Day5 do
  alias Aoc2023.Day5.Almanac
  alias Aoc2023.Day5.Range

  def as_integer(string) do
    {int, _} = Integer.parse(string)
    int
  end

  def get_soil(seed_id, almanac),
    do: convert_category(almanac.seeds_to_soil, seed_id)

  def get_fertilizer(soil_id, almanac),
    do: convert_category(almanac.soil_to_fertilizer, soil_id)

  def get_water(fertilizer_id, almanac),
    do: convert_category(almanac.fertilizer_to_water, fertilizer_id)

  def get_light(water_id, almanac),
    do: convert_category(almanac.water_to_light, water_id)

  def get_temperature(light_id, almanac),
    do: convert_category(almanac.light_to_temperature, light_id)

  def get_humidity(temperature_id, almanac),
    do: convert_category(almanac.temperature_to_humidity, temperature_id)

  def get_location(humidity_id, almanac),
    do: convert_category(almanac.humidity_to_location, humidity_id)

  defp convert_category(mapping, id) do
    mapping
    |> Enum.find(&Range.source_contains?(&1, id))
    |> case do
      nil -> id
      range -> Range.source_to_dest(range, id)
    end
  end

end

defmodule Aoc2023.Day5.Range do
  import Aoc2023.Day5

  defstruct [
    destination: 0,
    source: 0,
    length: 0
  ]

  def parse(range) do
    [d, s, l] =
      range
      |> String.split(" ", trim: true)
      |> Enum.map(&as_integer/1)

    %__MODULE__{
      destination: d,
      source: s,
      length: l
    }
  end

  def source_contains?(range, value) do
    range.source <= value and
      value < range.source + range.length
  end

  def destination_contains?(range, value) do
    range.destination <= value and
      value < range.destination + range.length
  end

  def source_to_dest(range, value) do
    range.destination + value - range.source
  end
end

defmodule Aoc2023.Day5.Almanac do
  import Aoc2023.Day5

  alias Aoc2023.Day5.Range

  defstruct [
    :seeds_as_single_values,
    :seeds_as_ranges,
    :seeds_to_soil,
    :soil_to_fertilizer,
    :fertilizer_to_water,
    :water_to_light,
    :light_to_temperature,
    :temperature_to_humidity,
    :humidity_to_location
  ]

  def parse(input) do
    parts =
      input
      |> File.read!()
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.trim/1)

    %__MODULE__{
      seeds_as_single_values: parse_seeds_single(Enum.at(parts, 0)),
      seeds_as_ranges: parse_seeds_range(Enum.at(parts, 0)),
      seeds_to_soil: parse_section(Enum.at(parts, 1)),
      soil_to_fertilizer: parse_section(Enum.at(parts, 2)),
      fertilizer_to_water: parse_section(Enum.at(parts, 3)),
      water_to_light: parse_section(Enum.at(parts, 4)),
      light_to_temperature: parse_section(Enum.at(parts, 5)),
      temperature_to_humidity: parse_section(Enum.at(parts, 6)),
      humidity_to_location: parse_section(Enum.at(parts, 7))
    }
  end

  defp parse_seeds_single(line) do
     [_, seeds] = String.split(line, ": ")
 
     seeds
     |> String.split(" ", trim: true)
     |> Enum.map(&as_integer/1)
  end

  defp parse_seeds_range(line) do
    line
    |> parse_seeds_single()
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, length] -> start..(start+length-1) end)
  end

  def parse_section(section) do
    [_ | values] = String.split(section, "\n")
    Enum.map(values, &Range.parse/1)
  end
end

defmodule Aoc2023.Day5.Part1 do
  alias Aoc2023.Day5.Almanac

  import Aoc2023.Day5

  def run(input) do
    almanac = input |> Almanac.parse()

    almanac.seeds_as_single_values
    |> Enum.map(fn seed_id ->
      seed_id
      |> get_soil(almanac)
      |> get_fertilizer(almanac)
      |> get_water(almanac)
      |> get_light(almanac)
      |> get_temperature(almanac)
      |> get_humidity(almanac)
      |> get_location(almanac)
    end)
    |> Enum.min()
  end
end

defmodule Aoc2023.Day5.Part2 do
  alias Aoc2023.Day5.Almanac

  import Aoc2023.Day5

  def run(input) do
    almanac = input |> Almanac.parse()

    almanac.seeds_as_ranges
    |> Enum.map(fn range ->
      range
      |> Enum.reduce(nil, fn seed_id, total_min_location ->
        partial_min_location = 
          seed_id
          |> get_soil(almanac)
          |> get_fertilizer(almanac)
          |> get_water(almanac)
          |> get_light(almanac)
          |> get_temperature(almanac)
          |> get_humidity(almanac)
          |> get_location(almanac)
        if is_nil(total_min_location),
          do: partial_min_location,
        else: min(partial_min_location, total_min_location)
      end)
    end)
    |> Enum.min()
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day5.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day5.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

