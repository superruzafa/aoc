#!/usr/bin/env elixir

defmodule Aoc2022.Day24 do

  defmodule Valley do
    defstruct [:blizzards, :blizzards_map, :size, :start, :goal]

    def new(map) do
      {start, goal} = find_start_goal(map)
      size = calculate_size(map)

      blizzards =
        Enum.reduce(map, [], fn
          {xy, {:blizzard, direction}}, blizzards -> [{xy, direction} | blizzards]
          _, blizzards -> blizzards
        end)

      blizzards_map = blizzards_to_map(blizzards)

      %__MODULE__{
        #map: map,
        blizzards: blizzards,
        blizzards_map: blizzards_map,
        start: start,
        goal: goal,
        size: size
      }
    end

    def step(%__MODULE__{} = valley) do
      blizzards = 
        Enum.map(valley.blizzards, fn blizzard -> 
          blizzard
          |> step_blizzard()
          |> wrap_blizzard(valley.size)
        end)

      blizzards_map = blizzards_to_map(blizzards)

      %{valley |
        blizzards: blizzards,
        blizzards_map: blizzards_map
      }

    end

    defp step_blizzard({{x, y}, :right}), do: {{x + 1, y}, :right}
    defp step_blizzard({{x, y}, :left}), do: {{x - 1, y}, :left}
    defp step_blizzard({{x, y}, :up}), do: {{x, y - 1}, :up}
    defp step_blizzard({{x, y}, :down}), do: {{x, y + 1}, :down}

    defp wrap_blizzard({{x, y}, :right}, {width, _}) when (width - 1) == x, do: {{1, y}, :right}
    defp wrap_blizzard({{x, y}, :left}, {width, _}) when x == 0, do: {{(width - 1) - 1, y}, :left}
    defp wrap_blizzard({{x, y}, :down}, {_, height}) when y == (height - 1), do: {{x, 1}, :down}
    defp wrap_blizzard({{x, y}, :up}, {_, height}) when y == 0, do: {{x, (height - 1) - 1}, :up}
    defp wrap_blizzard(blizzard, _size), do: blizzard

    def show(%__MODULE__{} = valley, elves \\ nil) do
      {width, height} = valley.size

      for y <- 0..height - 1 do
        for x <- 0..width - 1 do
          xy = {x, y}
          cond do
            xy == elves -> "E"
            xy == valley.start -> "."
            xy == valley.goal -> "."
            x in [0, width - 1] -> "#"
            y in [0, height - 1] -> "#"
            true ->
              case Map.get(valley.blizzards_map, xy) do
                [:right] -> ">"
                [:left] -> "<"
                [:up] -> "^"
                [:down] -> "v"
                blizzards when is_list(blizzards) -> blizzards |> length() |> Integer.to_string()
                _otherwise -> "."
              end
          end
          |> IO.write()
        end
        IO.puts("")
      end
      IO.puts("")

      valley
    end

    defp blizzards_to_map(blizzards) do
      Enum.reduce(blizzards, %{}, fn {xy, direction}, map ->
        Map.update(map, xy, [direction], fn blizzards -> [direction | blizzards] end)
      end)
    end

    defp find_start_goal(map) do
      map
      |> Enum.reduce({nil, nil, -1}, fn
        {{x, 0}, :ground}, {_start, goal, max_y} -> {{x, 0}, goal, max_y}
        {{x, y}, :ground}, {start, _goal, max_y} when y > max_y -> {start, {x, y}, y}
        _, acc -> acc
      end)
      |> case do
        {start, goal, _} -> {start, goal}
      end
    end

    defp calculate_size(map) do
      map
      |> Map.keys()
      |> Enum.reduce({0, 0}, fn
        {x, y}, {max_x, max_y} -> {max(x, max_x), max(y, max_y)}
      end)
      |> case do {x, y} -> {x + 1, y + 1} end
    end

    def can_move?(%__MODULE__{} = valley, {x, y} = xy) do
      {width, height} = valley.size

      cond do
        xy in [valley.start, valley.goal] -> true
        x < 1 or width < x -> false
        y < 1 or height < y -> false
        true -> true
      end
    end

    def has_blizzard(%__MODULE__{} = valley, {x, y} = xy) do
      Map.has_key?(valley.blizzards_map, xy)
    end

    def goal?(%__MODULE__{} = valley, xy), do: xy == valley.goal

  end

  defmodule Nodo do
    defstruct ~w(ci xy valley minute)a
  end

  def part1 do
    map = load()

    valley = Valley.new(map)


    valleys =
      Stream.iterate(0, &Kernel.+(1, &1))
      |> Enum.reduce_while({[valley], valley}, fn i, {[valley | _rest] = valleys, valley0} ->
        valley = Valley.step(valley)
        if valley == valley0 do
          {:halt, valleys |> Enum.reverse() |> Stream.cycle()}
        else
          valleys = [valley | valleys]
          {:cont, {valleys, valley0}}
        end
      end)

    ci = manhattan_distance(valley.start, valley.goal)

    nodes = [%{
      ci: ci,
      cost: ci,
      cs: nil,
      rel: :wait,
      xy: valley.start,
      minute: 0,
      sol: []
    }]

    run(valleys, nodes, nil)

    ""
  end

  defp run(_valleys, [], c), do: c

  defp run(valleys, [node | other_nodes] = nodes, c) do
    valley = Valley.step(node.valley)
    minute = node.minute + 1

    {other_nodes, c} = 
      cond do
        Valley.goal?(node.valley, node.xy) ->
          IO.inspect(c)
          IO.inspect(Enum.reverse(node.sol))
          c = if is_nil(c), do: node.cost, else: min(c, node.cost)
          other_nodes = Enum.reject(other_nodes, & &1.ci > c)
          {other_nodes, c}

        Valley.has_blizzard(valley, node.xy) ->
          {other_nodes, c}

        true ->
          nodes =
            build_movements(node.xy)
            |> Enum.filter(fn {_rel, xy} -> Valley.can_move?(valley, xy) end)

          nodes =
            nodes
            |> Enum.map(fn {step, xy} ->
              %{
                ci: minute  + manhattan_distance(node.xy, node.valley.goal),
                cost: minute + manhattan_distance(node.xy, node.valley.goal),
                cs: node.cs,
                xy: xy,
                sol: [step | node.sol],
                valley: valley,
                minute: minute
              }
            end)

          nodes = if is_nil(c),
            do: nodes,
            else: Enum.reject(nodes, & &1.ci > c)

          other_nodes = Enum.sort_by(nodes ++ other_nodes, & &1.cost)
          {other_nodes, c}
      end

    run(other_nodes, c)
        
  end


  defp manhattan_distance({x1, y1}, {x2, y2}), 
    do: abs(x2 - x1) + abs(y2 - y1)

  defp build_movements({x, y}) do
    [
      {:down, {x, y + 1}},
      {:right, {x + 1, y}},
      {:wait, {x, y}},
      {:left, {x - 1, y}},
      {:up, {x, y - 1}},
    ]
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(&parse_line/1)
    |> Enum.into(%{})
  end

  defp parse_line({line, y}) do
    line
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map(fn
      {"#", x} -> {{x, y}, :wall}
      {".", x} -> {{x, y}, :ground}
      {"^", x} -> {{x, y}, {:blizzard, :up}}
      {"v", x} -> {{x, y}, {:blizzard, :down}}
      {">", x} -> {{x, y}, {:blizzard, :right}}
      {"<", x} -> {{x, y}, {:blizzard, :left}}
    end)
  end

end

Aoc2022.Day24.part1()

