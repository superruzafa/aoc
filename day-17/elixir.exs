#!/usr/bin/env elixir
defmodule Aoc2022.Day17 do

  defmodule Stream do
    defstruct [:enum, :curr]

    def new(enum) do
      %__MODULE__{
        enum: enum,
        curr: 0
      }
    end

    def next(stream) do
      val = Enum.at(stream.enum, stream.curr)
      stream = %{stream | curr: rem(stream.curr + 1, length(stream.enum))}
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
    defstruct [:coords]

    def new(coords) do
      %__MODULE__{coords: coords}
    end

    def move(rock, :right), do: do_move(rock, +1)
    def move(rock, :left), do: do_move(rock, -1)

    defp do_move(rock, inc) do
      %{
        rock |
        coords: Enum.map(rock.coords, & XY.add(&1, inc))
      }
    end

  end

  defmodule Chamber do
    defstruct [
      :coords,
      :highest_rock_y
    ]

    def new do
      %__MODULE__{
        coords: %{},
        highest_rock_y: 0
      }
    end

    def put(chamber, rock, %XY{} = xy) do
      rock.coords
      |> Enum.reduce(chamber, fn rock_xy, chamber ->
        xy = XY.add(xy, rock_xy)
        %{
          chamber |
          highest_rock_y: max(chamber.highest_rock_y, xy.y + 1),
          coords: Map.put(chamber.coords, xy, :rock)
        }
      end)

    end

    def fits?(chamber, rock, xy) do
      rock.coords
      |> Enum.all?(fn rock_xy ->
        %{x: x, y: y} = rock_xy = XY.add(xy, rock_xy)
        cond do
          Map.has_key?(chamber.coords, rock_xy) -> false
          x < 0 -> false
          x > 6 -> false
          y < 0 -> false
          true -> true
        end
      end)
    end

    def show(chamber) do
      for y <- chamber.highest_rock_y..0 do
        IO.write("|")
        for x <- 0..6 do
          xy = XY.new(x, y)
          (if Map.has_key?(chamber.coords, xy), do: "#", else: ".")
          |> IO.write()
        end
        IO.write("|")
        IO.puts("")
      end
      IO.puts("---------")

      chamber
    end

    def show(chamber, rock, rock_xy) do
      falling_rock = %{rock | coords: Enum.map(rock.coords, &XY.add(&1, rock_xy))}
      max_falling_rock_y = Enum.map(falling_rock.coords, & &1.y) |> Enum.max()
      for y <- max(chamber.highest_rock_y, max_falling_rock_y)..0 do
        IO.write("|")
        for x <- 0..6 do
          xy = XY.new(x, y)
          cond do
            xy in falling_rock.coords -> "@"
            Map.has_key?(chamber.coords, xy) -> "#"
            true -> "."
          end
          |> IO.write()
        end
        IO.write("|")
        IO.puts("")
      end
      IO.puts("---------")

      chamber
    end

  end

  def part1 do
    jet_pattern = load()
    rock_stream = build_rock_stream()
    chamber = Chamber.new()

    next_rock_phase(chamber, rock_stream, jet_pattern, 0)
    |> case do chamber -> chamber.highest_rock_y end

  end

  defp next_rock_phase(chamber, _, _, 1_000_000_000_000) do
    chamber
  end

  defp next_rock_phase(chamber, rock_stream, jet_pattern, rock_count) do
    if rem(rock_count, 1_000) == 0 do
      IO.inspect(rock_count)
    end

    {rock_stream, rock} = Stream.next(rock_stream)
    rock_xy = XY.new(2, chamber.highest_rock_y + 3)
    jet_pattern_phase(chamber, rock_stream, rock, rock_xy, jet_pattern, rock_count)
  end

  defp jet_pattern_phase(chamber, rock_stream, rock, rock_xy, jet_pattern, rock_count) do
    {jet_pattern, jet_direction} = Stream.next(jet_pattern)
    attempt_rock_xy =
      case jet_direction do
        :left -> XY.add(rock_xy, XY.new(-1, 0))
        :right -> XY.add(rock_xy, XY.new(+1, 0))
      end

    rock_xy = if Chamber.fits?(chamber, rock, attempt_rock_xy), do: attempt_rock_xy, else: rock_xy
    #Chamber.show(chamber, rock, rock_xy)
    fall_phase(chamber, rock_stream, rock, rock_xy, jet_pattern, rock_count)
  end

  def fall_phase(chamber, rock_stream, rock, rock_xy, jet_pattern, rock_count) do
    attempt_rock_xy = XY.add(rock_xy, XY.new(0, -1))
    if Chamber.fits?(chamber, rock, attempt_rock_xy) do
      jet_pattern_phase(chamber, rock_stream, rock, attempt_rock_xy, jet_pattern, rock_count)
    else
      chamber = Chamber.put(chamber, rock, rock_xy)
      #Chamber.show(chamber)
      next_rock_phase(chamber, rock_stream, jet_pattern, rock_count + 1)
    end
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
    rock = """
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
    |> Rock.new()
  end






end

IO.puts("# positions cannot contain a beacon (part 1): #{Aoc2022.Day17.part1()}")
#IO.puts("missing beacon's tunning frequency (part 2): #{Aoc2022.Day17.part2()}")

