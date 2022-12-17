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
      :remaining_rocks,
      :highest_rock_y
    ]

    def new(remaining_rocks) do
      %__MODULE__{
        coords: MapSet.new(),
        remaining_rocks: remaining_rocks,
        highest_rock_y: 0
      }
    end

    def put(chamber, rock) do
      %{
        chamber |
        remaining_rocks: chamber.remaining_rocks - 1,
        highest_rock_y: max(chamber.highest_rock_y, rock.boundaries.up + 1),
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
      for y <- chamber.highest_rock_y..0 do
        IO.write("|")
        for x <- 0..6 do
          xy = XY.new(x, y)
          (if MapSet.member?(chamber.coords, xy), do: "#", else: ".")
          |> IO.write()
        end
        IO.write("|")
        IO.puts("")
      end
      IO.puts("---------")
      IO.puts("")

      chamber
    end

    def show(chamber, rock) do
      for y <- max(chamber.highest_rock_y, rock.boundaries.up)..0 do
        IO.write("|")
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
      IO.puts("---------")
      IO.puts("")

      chamber
    end

  end

  def part1 do
    jet_pattern = load()
    rock_stream = build_rock_stream()
    chamber = Chamber.new(2022)

    phase(:next_rock, chamber, rock_stream, nil, jet_pattern)
    |> case do chamber -> chamber.highest_rock_y end
  end

  def part2 do
    jet_pattern = load()
    rock_stream = build_rock_stream()
    chamber = Chamber.new(1_000_000_000_000)

    phase(:next_rock, chamber, rock_stream, nil, jet_pattern)
    |> case do chamber -> chamber.highest_rock_y end
  end

  defp phase(:next_rock, chamber, _rock_stream, _rock, _jet_pattern)
    when chamber.remaining_rocks == 0, do: chamber

  defp phase(:next_rock, chamber, rock_stream, _rock, jet_pattern) do
    {rock_stream, rock} = Stream.next(rock_stream)
    xy = XY.new(2, chamber.highest_rock_y + 3)
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
IO.puts("rock height after 1.000.000.000.000 rocks (part 1): #{Aoc2022.Day17.part2()}")

