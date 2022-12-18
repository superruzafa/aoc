#!/usr/bin/env elixir
defmodule Aoc2022.Day17 do

  defmodule Stream do
    defstruct [:enum, :length, :curr]

    def new(enum) do
      enum =
        enum
        |> Enum.with_index()
        |> Enum.map(fn {v, i} -> {i, v} end)
        |> Enum.into(%{})

      %__MODULE__{
        enum: enum,
        length: map_size(enum),
        curr: 0
      }
    end

    def next(%__MODULE__{} = stream) do
      val = Map.fetch!(stream.enum, stream.curr)
      stream = %{stream | curr: rem(stream.curr + 1, stream.length)}
      {stream, val}
    end
  end

  defmodule XY do
    defstruct [:x, :y]

    def new(x \\ 0, y \\ 0), do: %__MODULE__{x: x, y: y}

    def add(%XY{x: x1, y: y1}, %XY{x: x2, y: y2}),
      do: %XY{x: x1 + x2, y: y1 + y2}
  end

  defmodule Rock do
    defstruct [:coords, :xy, :boundaries]

    def new(%MapSet{} = coords) do
      boundaries =
        coords
        |> Enum.reduce(%{}, fn %{x: x, y: y}, b ->
          %{
            right: max(x, Map.get(b, :right, 0)),
            left: min(x, Map.get(b, :left, 0)),
            up: max(y, Map.get(b, :up, 0)),
            down: min(y, Map.get(b, :down, 0))
          }
        end)

      %__MODULE__{
        coords: coords,
        xy: XY.new(),
        boundaries: boundaries
      }

    end

    @left_shift XY.new(-1, 0)
    @right_shift XY.new(+1, 0)
    @down_shift XY.new(0, -1)

    def shift(rock, :down), do: shift(rock, @down_shift)

    def shift(rock, :left), do: shift(rock, @left_shift)

    def shift(rock, :right), do: shift(rock, @right_shift)

    def shift(rock, %XY{x: x, y: y} = xy) do
      %{
        rock |
        xy: XY.add(rock.xy, xy),
        coords: Enum.map(rock.coords, &XY.add(&1, xy)) |> MapSet.new(),
        boundaries: %{
          up: rock.boundaries.up + y,
          down: rock.boundaries.down + y,
          right: rock.boundaries.right + x,
          left: rock.boundaries.left + x,
        }
      }
    end

  end

  defmodule Chamber do
    defstruct [
      :coords,
      :highest_y,
      :rocks,
      :milestone_rocks,
      :milestone_y
    ]

    def new(opts \\ []) do
      milestone_rocks = Keyword.get(opts, :milestone_rocks)
      milestone_y = Keyword.get(opts, :milestone_y)

      %__MODULE__{
        coords: MapSet.new(),
        highest_y: 0,
        rocks: 0,
        milestone_rocks: milestone_rocks,
        milestone_y: milestone_y
      }
    end

    def reset_opt(chamber, opts \\ []) do
      milestone_rocks = Keyword.get(opts, :milestone_rocks)
      milestone_y = Keyword.get(opts, :milestone_y)
      %{
        chamber |
        milestone_rocks: milestone_rocks,
        milestone_y: milestone_y
      }
    end

    def put(chamber, rock) do
      %{
        chamber |
        rocks: chamber.rocks + 1,
        highest_y: max(chamber.highest_y, rock.boundaries.up + 1),
        coords: MapSet.union(chamber.coords, rock.coords),
      }
    end

    def can_be_placed?(chamber, rock) do
      cond do
        rock.boundaries.left < 0 -> false
        rock.boundaries.right > 6 -> false
        rock.boundaries.down < 0 -> false
        true -> MapSet.disjoint?(chamber.coords, rock.coords)
      end
    end

    def show(chamber) do
      for y <- chamber.highest_y..0 do
        IO.write("#{y |> Integer.to_string() |> String.pad_leading(6, "0")} |")
        for x <- 0..6 do
          xy = XY.new(x, y)
          (if MapSet.member?(chamber.coords, xy), do: "#", else: ".")
          |> IO.write()
        end
        IO.write("|")
        IO.puts("")
      end
      IO.puts("       ---------")
      IO.puts("")

      chamber
    end

    def show(chamber, rock) do
      for y <- max(chamber.highest_y, rock.boundaries.up)..0 do
        IO.write("#{y |> Integer.to_string() |> String.pad_leading(6, "0")} |")
        for x <- 0..6 do
          xy = XY.new(x, y)
          cond do
            xy in rock.coords -> "@"
            xy in chamber.coords -> "#"
            true -> "."
          end
          |> IO.write()
        end
        IO.write("|")
        IO.puts("")
      end
      IO.puts("       ---------")
      IO.puts("")

      chamber
    end

    def row(chamber, y) do
      for x <- 0..6 do
        if MapSet.member?(chamber.coords, XY.new(x, y)), do: "#", else: "."
      end
      |> Enum.join()
    end

    def encode(chamber, y) do
      for x <- 0..6 do
        if MapSet.member?(chamber.coords, XY.new(x, y)), do: trunc(Float.pow(2.0, 6 - x)), else: 0
      end
      |> Enum.sum()
    end

  end

  def part1 do
    jet_pattern = load()
    rock_stream = build_rock_stream()
    chamber = Chamber.new(milestone_rocks: 2022)

    phase(:next_rock, chamber, rock_stream, nil, jet_pattern)
    |> case do {chamber, _, _} -> chamber.highest_y end
  end

  def part2 do
    jet_pattern = load()
    rock_stream = build_rock_stream()
    chamber = Chamber.new(milestone_rocks: 500_000)
    part2_pattern(chamber, rock_stream, jet_pattern)
  end

  defp part2_pattern(chamber, rock_stream, jet_pattern) do
    {chamber, rock_stream, jet_pattern} = phase(:next_rock, chamber, rock_stream, nil, jet_pattern)
    IO.puts("simulation ended, trying to find pattern...")

    chamber
    |> find_pattern()
    |> case do
      nil ->
        IO.puts("cannot find pattern with rock milestone = #{chamber.milestone_rocks}, increasing...")
        chamber
        |> Chamber.reset_opt(milestone_rocks: chamber.milestone_rocks + 1_000_000)
        |> part2_pattern(rock_stream, jet_pattern)

      {start, length} -> 
        IO.puts("pattern found! start: #{start} length: #{length}")
        #demonstrate(chamber, start, length)
        extrapolate_simulation(start, length, 1_000_000_000_000)
    end
  end

  defp demonstrate(chamber, start, length) do
    sequence =
      for y <- 0..chamber.highest_y do
        {y, Chamber.row(chamber, y)}
      end
      |> Enum.into(%{})

    for i <- 0..length - 1 do
      for o <- 0..2 do
        pos = start + length * o + i
        IO.write("#{pos |> Integer.to_string() |> String.pad_leading(3, "0")} :")
        a = Map.get(sequence, pos)
        IO.write(a)
        IO.write(" ")
      end
      IO.puts("")
    end
  end

  defp extrapolate_simulation(start, length, target_rocks) do
    jet_pattern = load()
    rock_stream = build_rock_stream()

    chamber = Chamber.new(milestone_y: start)
    {chamber, rock_stream, jet_pattern} = phase(:next_rock, chamber, rock_stream, nil, jet_pattern)
    rocks_at_pattern_start = chamber.rocks
    height_at_pattern_start = chamber.highest_y

    chamber = Chamber.reset_opt(chamber, milestone_y: start + length)
    {chamber, rock_stream, jet_pattern} = phase(:next_rock, chamber, rock_stream, nil, jet_pattern)
    rocks_per_pattern = (chamber.rocks - rocks_at_pattern_start)
    height_per_pattern = (chamber.highest_y - height_at_pattern_start)

    remaining_rocks = target_rocks - rocks_at_pattern_start
    full_patterns_needed = remaining_rocks / rocks_per_pattern |> floor() |> trunc()
    rocks_last_pattern = rem(remaining_rocks, rocks_per_pattern)

    chamber = Chamber.reset_opt(chamber, milestone_rocks: chamber.rocks + rocks_last_pattern)
    {chamber, _rock_stream, _jet_pattern} = phase(:next_rock, chamber, rock_stream, nil, jet_pattern)
    height_added_in_last_pattern = (chamber.highest_y - height_per_pattern - height_at_pattern_start)

    IO.puts("""
# rocks when pattern starts: #{rocks_at_pattern_start}
# height when pattern starts: #{height_at_pattern_start}
# rocks per pattern: #{rocks_per_pattern}
# height added per pattern: #{height_per_pattern}
# rocks last pattern = #{rocks_last_pattern}
# full patterns needed: #{full_patterns_needed}
# height added in last partial pattern: #{height_added_in_last_pattern}
""")

    height_at_pattern_start + (full_patterns_needed * height_per_pattern) + height_added_in_last_pattern
  end

  defp find_pattern(chamber) do
    sequence =
      for y <- 0..chamber.highest_y do
        {y, Chamber.encode(chamber, y)}
      end
      |> Enum.into(%{})

    0..chamber.highest_y
    |> Enum.find_value(fn i -> do_find_pattern(sequence, i) end)
  end

  defp do_find_pattern(sequence, start) do
    x = Map.fetch!(sequence, start)
    repetitions = Map.filter(sequence, fn {k, v} -> k > start and v == x end)
    Enum.find_value(repetitions, fn {i, _} -> pattern?(sequence, start, i) end)
  end

  defp pattern?(sequence, start, length) do
    x = Map.fetch!(sequence, start)
    positions = 1..3 |> Enum.map(& (start + length * &1))
    if Enum.all?(positions, &Map.get(sequence, &1) == x) and verify_pattern(sequence, start, length, length) do
      {start, length}
    else
      false
    end
  end

  defp verify_pattern(_sequence, _start, _length, 0), do: true

  defp verify_pattern(sequence, start, length, remaining) do
    if Map.get(sequence, start) == Map.get(sequence, start + length) do
      verify_pattern(sequence, start + 1, length, remaining - 1)
    else
      false
    end
  end

  defp phase(:next_rock, chamber, rock_stream, _rock, jet_pattern)
    when not is_nil(chamber.milestone_rocks) and chamber.rocks == chamber.milestone_rocks,
    do: {chamber, rock_stream, jet_pattern}

  defp phase(:next_rock, chamber, rock_stream, _rock, jet_pattern)
    when not is_nil(chamber.milestone_y) and chamber.highest_y >= chamber.milestone_y,
    do: {chamber, rock_stream, jet_pattern}

  defp phase(:next_rock, chamber, rock_stream, _rock, jet_pattern) do
    {rock_stream, rock} = Stream.next(rock_stream)
    xy = XY.new(2, chamber.highest_y + 3)
    rock = Rock.shift(rock, xy)
    phase(:jet, chamber, rock_stream, rock, jet_pattern)
  end

  defp phase(:jet, chamber, rock_stream, rock, jet_pattern) do
    {jet_pattern, jet_direction} = Stream.next(jet_pattern)
    rock_test = Rock.shift(rock, jet_direction)
    rock = if Chamber.can_be_placed?(chamber, rock_test), do: rock_test, else: rock
    phase(:rock_fall, chamber, rock_stream, rock, jet_pattern)
  end

  defp phase(:rock_fall, chamber, rock_stream, rock, jet_pattern) do
    rock_test = Rock.shift(rock, :down)
    {next_phase, chamber, rock} =
      if Chamber.can_be_placed?(chamber, rock_test) do
        {:jet, chamber, rock_test}
      else
        chamber = Chamber.put(chamber, rock)
        {:next_rock, chamber, rock}
      end
    phase(next_phase, chamber, rock_stream, rock, jet_pattern)
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.codepoints()
    |> Enum.map(& case &1 do
      ">" -> :right
      "<" -> :left
      _ -> nil
    end)
    |> Enum.reject(& is_nil/1)
    |> Stream.new()
  end

  defp build_rock_stream do
    Stream.new(build_rocks())
  end

  defp build_rocks do
    """
####

.#.
###
.#.

..#
..#
###

#
#
#
#

##
##
"""
|> String.split("\n\n", trim: true)
|> Enum.map(&parse_rock/1)
  end

  defp parse_rock(rock) do
    rock
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {t, _} -> t == "#" end)
      |> Enum.map(fn {_, x} -> XY.new(x, y) end)
    end)
    |> MapSet.new()
    |> Rock.new()
  end

end

IO.puts("rock height after 2.022 rocks (part 1): #{Aoc2022.Day17.part1()}")
IO.puts("rock height after 1.000.000.000.000 rocks (part 2): #{Aoc2022.Day17.part2()}")

