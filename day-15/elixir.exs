#!/usr/bin/env elixir
defmodule Aoc2022.Day15 do

  defmodule XY do
    defstruct [:x, :y]

    def new(x \\ 0, y \\ 0), do: %__MODULE__{x: x, y: y}

    def manhattan_distance(%__MODULE__{} = xy1, %__MODULE__{} = xy2) do
      abs(xy1.x - xy2.x) + abs(xy1.y - xy2.y)
    end

    def left(%__MODULE__{} = xy, amount) do
      %{xy | x: xy.x - amount}
    end

    def right(%__MODULE__{} = xy, amount) do
      %{xy | x: xy.x + amount}
    end

    def nl(%__MODULE__{} = xy) do
      %{xy | x: 0, y: xy.y + 1}
    end

  end

  defmodule Sensor do
    defstruct [
      sensor_xy: nil,
      beacon_xy: nil,
      radius: nil
    ]

    def new(%XY{} = sensor_xy, %XY{} = beacon_xy) do
      %__MODULE__{
        sensor_xy: sensor_xy,
        beacon_xy: beacon_xy,
        radius: XY.manhattan_distance(sensor_xy, beacon_xy)
      }
    end

    def covers?(%__MODULE__{} = sensor, %XY{} = xy) do
      xy_radius = XY.manhattan_distance(sensor.sensor_xy, xy)
      xy_radius <= sensor.radius
    end

    def next_point_out_of_sensor(%__MODULE__{} = sensor, xy) do
      %{sensor_xy: %{x: sx, y: sy}, radius: radius} = sensor
      x = sx + radius - abs(sy - xy.y) + 1
      XY.new(x, xy.y)
    end
  end
  
  @part_1_line_y 2_000_000

  def part1 do
    sensors = load()

    map_line_x =
      sensors
      |> Enum.map(& &1.beacon_xy)
      |> Enum.filter(& &1.y == @part_1_line_y)
      |> Enum.reduce(%{}, & Map.put(&2, &1, :beacon))

    map_line_x =
      sensors
      |> Enum.reduce(map_line_x, fn sensor, map_line_x ->
          %{sensor_xy: %{x: sx, y: sy}, radius: radius} = sensor
          if abs(@part_1_line_y - sy) <= radius do
            signal_section_count = radius - abs(sy - @part_1_line_y)

            XY.new(sx, @part_1_line_y)
            |> generate_signals(signal_section_count)
            |> Enum.reduce(map_line_x, & Map.put_new(&2, &1, :signal))

          else
            map_line_x

          end
        end
      )

    Enum.count(map_line_x, fn {_, type} -> type == :signal end)
  end

  defp generate_signals(%XY{} = xy, 0), do: [xy]

  defp generate_signals(%XY{} = xy, n) do
    [
      XY.left(xy, n),
      XY.right(xy, n)
    ] ++
    generate_signals(xy, n - 1)
  end



  #@limit 20
  @limit 4_000_000

  def part2 do
    load()
    |> run(XY.new())
    |> case do %XY{x: x, y: y} -> x * @limit + y end
  end

  defp run(sensors, xy) do
    sensors
    |> Enum.find(& Sensor.covers?(&1, xy))
    |> case do
      nil -> xy
      sensor ->
        xy = Sensor.next_point_out_of_sensor(sensor, xy)
        xy = if @limit < xy.x, do: XY.nl(xy), else: xy
        xy = if @limit < xy.y, do: nil, else: xy
        run(sensors, xy)
    end
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  @regex ~r/Sensor at x=(?<sx>-?\d+), y=(?<sy>-?\d+): closest beacon is at x=(?<bx>-?\d+), y=(?<by>-?\d+)/ 

  defp parse_line(line) do
    matches = Regex.named_captures(@regex, line)
    sx = Map.fetch!(matches, "sx") |> String.to_integer()
    sy = Map.fetch!(matches, "sy") |> String.to_integer()
    bx = Map.fetch!(matches, "bx") |> String.to_integer()
    by = Map.fetch!(matches, "by") |> String.to_integer()

    sensor_xy = XY.new(sx, sy)
    beacon_xy = XY.new(bx, by)
    Sensor.new(sensor_xy, beacon_xy)
  end

end

IO.puts("# positions cannot contain a beacon (part 1): #{Aoc2022.Day15.part1()}")
IO.puts("missing beacon's tunning frequency (part 2): #{Aoc2022.Day15.part2()}")

