#!/usr/bin/env elixir
defmodule Aoc2022.Day11 do

  defmodule Game do
    defstruct [
      monkeys: nil,
      worriedness_updater: nil
    ]
  end

  defmodule Monkey do
    defstruct [
      index: nil,
      times_inspecting: 0,
      items: nil,
      worriedness_updater: nil,
      divider: nil,
      if_true: nil,
      if_false: nil
    ]
  end

  defmodule Util do
    def gcd(a, 0), do: a
    def gcd(0, b), do: b
    def gcd(a, b), do: gcd(b, rem(a, b))
    
    def lcm(0, 0), do: 0
    def lcm(a, b), do: div((a * b), gcd(a, b))
  end

  defimpl Inspect, for: Monkey do
    def inspect(monkey, _opts) do
      items = monkey.items |> Enum.map(&Integer.to_string/1) |> Enum.join(",")
      """
      Monkey ##{monkey.index}: items: #{items}, times_inspecting: #{monkey.times_inspecting}
      """
    end
  end

  def part1 do
    monkeys = load() 

    game = %Game{
      monkeys: monkeys,
      worriedness_updater: & div(&1, 3)
    }

    1..20
    |> Enum.reduce(game, fn _round, game -> play_round(game) end)
    |> case do %Game{monkeys: monkeys} -> monkeys end
    |> Map.values()
    |> Enum.map(& &1.times_inspecting)
    |> Enum.sort(& >/2)
    |> Enum.take(2)
    |> Enum.product()
  end

  def part2 do
    monkeys = load() 

    lcm =
      monkeys
      |> Map.values()
      |> Enum.map(& &1.divider)
      |> Enum.reduce(& Util.lcm/2)

    game = %Game{
      monkeys: monkeys,
      worriedness_updater: & rem(&1, lcm)
    }

    1..10000
    |> Enum.reduce(game, fn _round, game -> play_round(game) end)
    |> case do %Game{monkeys: monkeys} -> monkeys end
    |> Map.values()
    |> Enum.map(& &1.times_inspecting)
    |> Enum.sort(& >/2)
    |> Enum.take(2)
    |> Enum.product()
  end

  defp play_round(game) do
    game
    |> Map.fetch!(:monkeys)
    |> Map.keys()
    |> Enum.reduce(game, fn monkey_index, game ->
      monkey = game |> Map.fetch!(:monkeys) |> Map.fetch!(monkey_index)
      play_monkey_round(monkey, monkey.items, game)
    end)
  end

  defp play_monkey_round(_monkey, [], game), do: game

  defp play_monkey_round(monkey, [item | items], game) do
    %{
      monkeys: monkeys,
      worriedness_updater: game_worriedness_updater
    } = game

    %{
      worriedness_updater: monkey_worriedness_updater,
      times_inspecting: times_inspecting
    } = monkey

    item =
      item 
      |> monkey_worriedness_updater.() 
      |> game_worriedness_updater.()

    monkey = %{monkey |
      items: [item | items],
      times_inspecting: times_inspecting + 1
    }
    monkeys = update_monkeys(monkeys, monkey)

    target_monkey_index =
      if rem(item, monkey.divider) == 0,
        do: monkey.if_true,
        else: monkey.if_false
    monkeys = throw_item(monkeys, monkey.index, target_monkey_index)

    game = %{game | monkeys: monkeys}
    play_monkey_round(monkey, items, game)
  end

  defp update_monkeys(monkeys, monkey),
    do: Map.put(monkeys, monkey.index, monkey)

  defp throw_item(monkeys, monkey_from_index, monkey_to_index) do
    monkey_from = Map.fetch!(monkeys, monkey_from_index)
    monkey_to = Map.fetch!(monkeys, monkey_to_index)
    [item | items_from] = monkey_from.items
    items_to = monkey_to.items ++ [item]
    monkey_from = %{monkey_from | items: items_from}
    monkey_to = %{monkey_to | items: items_to}

    monkeys
    |> Map.put(monkey_from_index, monkey_from)
    |> Map.put(monkey_to_index, monkey_to)
  end

  defp load do
    "./input.txt"
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.with_index()
    |> Enum.map(&parse_monkey/1)
    |> Enum.with_index()
    |> Enum.map(fn {monkey, i} -> {i, monkey} end)
    |> Enum.into(%{})
  end

  defp parse_monkey({monkey_spec, index}) do
    monkey = %Monkey{
      index: index
    }

    monkey_spec
    |> String.split("\n", trim: true)
    |> Enum.reduce(monkey, &parse_monkey_line/2)
  end

  defp parse_monkey_line("  Starting items: " <> items, monkey) do
    items = 
      items
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)
    %{monkey | items: items}
  end

  defp parse_monkey_line("  Operation: " <> worriedness_updater, monkey) do
    regex1 = ~r/new = old \+ (?<value>\d+)/
    regex2 = ~r/new = old \* (?<value>\d+)/
    regex3 = ~r/new = old \* old/

    worriedness_updater =
      cond do
        matches = Regex.named_captures(regex1, worriedness_updater) ->
          %{"value" => value} = matches
          value = String.to_integer(value)
          fn old -> old + value end 
        
        matches = Regex.named_captures(regex2, worriedness_updater) ->
          %{"value" => value} = matches
          value = String.to_integer(value)
          fn old -> old * value end

        Regex.named_captures(regex3, worriedness_updater) ->
          fn old -> old * old end
      end

    %{monkey | worriedness_updater: worriedness_updater}
  end

  defp parse_monkey_line("  Test: divisible by " <> number, monkey) do
    number = String.to_integer(number)
    %{monkey | divider: number}
  end

  defp parse_monkey_line("    If true: throw to monkey " <> monkey_num, monkey) do
    monkey_num = String.to_integer(monkey_num)
    %{monkey | if_true: monkey_num}
  end

  defp parse_monkey_line("    If false: throw to monkey " <> monkey_num, monkey) do
    monkey_num = String.to_integer(monkey_num)
    %{monkey | if_false: monkey_num}
  end

  defp parse_monkey_line(_, monkey), do: monkey

end

IO.puts("monkey business (part 1): #{Aoc2022.Day11.part1()}")
IO.puts("monkey business (part 2): #{Aoc2022.Day11.part2()}")

