#!/usr/bin/env elixir
defmodule Aoc2022.Day16 do

  defmodule Valve do
    defstruct [:name, :flow_rate, :exits, :status]

    def new(name, flow_rate, exits) do
      %__MODULE__{
        name: name,
        flow_rate: flow_rate,
        exits: exits,
        status: :closed
      }
    end

    def open(%__MODULE__{} = valve) do
      %{valve | status: :open}
    end

    def closed?(%__MODULE__{status: :closed}), do: true
    def closed?(%__MODULE__{}), do: false

  end

  def part1 do
    valves = load()
    #|> IO.inspect()
    #exit(:normal)

    run(valves, Map.fetch!(valves, "AA"), 30, 0, MapSet.new())
    |> IO.inspect()

    ""
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(& {&1.name, &1})
    |> Enum.into(%{})
  end

  def run(_valves, _valve, 0, flow_rate, opened_valves) do
    {flow_rate, opened_valves}
  end

  def run(valves, %Valve{} = valve, remaining, flow_rate, opened_valves) do
    cond do
      all_valves_opened?(valves, opened_valves) ->
        {flow_rate, opened_valves}

      valve.flow_rate > 0 and Valve.closed?(valve) ->
        [
          run_opening_valve(valves, valve, remaining - 1, flow_rate, opened_valves),
          run_chosing_exit(valves, valve, remaining - 1, flow_rate, opened_valves)
        ]
        |> Enum.max_by(fn {a, _} -> a end)

      true ->
        run_chosing_exit(valves, valve, remaining - 1, flow_rate, opened_valves)
    end
  end

  defp run_opening_valve(valves, %Valve{status: :closed} = valve, remaining, flow_rate, opened_valves) do
    valve = Valve.open(valve)
    opened_valves = MapSet.put(opened_valves, valve.name)
    valves = Map.put(valves, valve.name, valve)
    flow_rate = flow_rate + valve.flow_rate * remaining
    #IO.puts("Opening valve: #{valve.name} remaining time: #{remaining} flow_rate: #{flow_rate}")
    run(valves, valve, remaining, flow_rate, opened_valves)
  end

  defp run_chosing_exit(valves, %Valve{} = valve, remaining, flow_rate, opened_valves) do
    valve.exits
    |> priorize(opened_valves)
    |> Enum.map(fn valve_name ->
      run(valves, Map.fetch!(valves, valve_name), remaining, flow_rate, opened_valves)
    end)
    |> Enum.max_by(fn {a, _} -> a end)
  end

  defp priorize(valve_names, opened_valves) do
    valve_names
    |> Enum.sort_by(fn valve_name ->
      if MapSet.member?(opened_valves, valve_name), do: 100, else: -100
    end)
  end

  defp all_valves_opened?(valves, opened_valves) do
    valves
    |> Enum.reject(fn {valve_name, _valve} -> MapSet.member?(opened_valves, valve_name) end)
    |> IO.inspect()
    |> Enum.all?(fn {_, valve} -> valve.flow_rate == 0 end)
  end

  @regex ~r/Valve (?<name>\w{2}) has flow rate=(?<flow_rate>\d+); tunnels? leads? to valves? (?<exits>\w{2}(?:, \w{2})*)/

  defp parse_line(line) do
    @regex
    |> Regex.named_captures(line)
    |> case do
      matches ->
        Valve.new(
          Map.fetch!(matches, "name"),
          matches |> Map.fetch!("flow_rate") |> String.to_integer(),
          matches |> Map.fetch!("exits") |> String.split(~r/,\s/)
        )
    end

  end

end

IO.puts("# positions cannot contain a beacon (part 1): #{Aoc2022.Day16.part1()}")
#IO.puts("missing beacon's tunning frequency (part 2): #{Aoc2022.Day16.part2()}")

