#!/usr/bin/env elixir
defmodule Aoc2022.Day5.Part1 do
  def run do
    lines =
      File.read!("./input.txt")
      |> String.split("\n")

    {crates, movements} = parse(lines)
    run_engine(crates, movements)
  end

  def run_engine(crates, movements) do
    Enum.reduce(movements, crates, &run_step/2)
    |> Enum.map(fn {_k, [top | _rest]} -> top end)
    |> Enum.join()
  end

  def run_step(movement, crates) do
    from_stack = Map.fetch!(crates, movement.from)
    to_stack = Map.fetch!(crates, movement.to)

    {temp_stack, from_stack} = Enum.split(from_stack, movement.count)

    crates
    |> Map.put(movement.from, from_stack)
    |> Map.put(movement.to, Enum.reverse(temp_stack) ++ to_stack)
  end

  def parse(lines) do
    lines
    |> Enum.split_while(& &1 != "")
    |> case do
      {crate_lines, movement_lines} ->
        {parse_crate_lines(crate_lines), parse_movement_lines(movement_lines)}
    end
  end

  def parse_crate_lines(lines) do
    lines
    |> Enum.drop(-1)
    |> Enum.reverse()
    |> Enum.map(&parse_crate_line/1)
    |> build_crates()
  end

  def parse_crate_line(line) do
    line 
    |> String.codepoints()
    |> Enum.chunk_every(4) 
    |> Enum.map(&Enum.join/1) 
    |> Enum.map(&String.at(&1, 1))
    |> Enum.map(&String.trim/1)
  end

  def build_crates(crate_row) do
    crates = Enum.reduce(1..9, %{}, fn i, acc -> Map.put_new(acc, i, []) end)
    Enum.reduce(crate_row, crates, &insert_into_crate_stack/2)
  end

  def insert_into_crate_stack(crate_row, crates) do
    crate_row
    |> Enum.with_index(1)
    |> Enum.reduce(crates, fn
      {"", _col}, crates -> crates
      {letter, col}, crates -> Map.update!(crates, col, fn l -> [letter | l] end)
    end)
  end

  def parse_movement_lines(lines) do
    lines
    |> Enum.drop(1)
    |> Enum.map(&parse_movement_line/1)
    |> Enum.reject(&is_nil/1)
  end

  def parse_movement_line(line) do
    ~r/move (?<count>\d+) from (?<from>\d+) to (?<to>\d+)/
    |> Regex.named_captures(line)
    |> case do
      nil -> nil
      %{"count" => count, "from" => from, "to" => to} ->
        %{
          count: String.to_integer(count),
          from: String.to_integer(from),
          to: String.to_integer(to)
        }
    end
  end

end

defmodule Aoc2022.Day5.Part2 do
  import Aoc2022.Day5.Part1, except: [run: 0, run_engine: 2, run_step: 2]

  def run do
    lines =
      File.read!("./input.txt")
      |> String.split("\n")

    {crates, movements} = parse(lines)
    run_engine(crates, movements)
  end

  def run_engine(crates, movements) do
    Enum.reduce(movements, crates, &run_step/2)
    |> Enum.map(fn {_k, [top | _rest]} -> top end)
    |> Enum.join()
  end

  def run_step(movement, crates) do
    from_stack = Map.fetch!(crates, movement.from)
    to_stack = Map.fetch!(crates, movement.to)

    {temp_stack, from_stack} = Enum.split(from_stack, movement.count)

    crates
    |> Map.put(movement.from, from_stack)
    |> Map.put(movement.to, temp_stack ++ to_stack)
  end
end

IO.puts("Crates movement (part 1): #{Aoc2022.Day5.Part1.run()}")
IO.puts("Crates movement (part 2): #{Aoc2022.Day5.Part2.run()}")

