defmodule Aoc2023.Day12.Cache do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn cache ->
      Map.get(cache, key)
    end)
  end

  def set(key, value) do
    Agent.update(__MODULE__, fn cache ->
      Map.put(cache, key, value)
    end)
  end

  def stop do
    Agent.stop(__MODULE__)
  end
end

defmodule Aoc2023.Day12 do
  alias __MODULE__.Cache

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [springs, groups] = String.split(line, " ")
    groups = groups |> String.split(",") |> Enum.map(&as_integer/1)

    {springs, groups}
  end

  defp as_integer(string) do
    {int, _} = Integer.parse(string)
    int
  end

  def unfold({springs, groups}) do
    springs =
      springs
      |> List.duplicate(5)
      |> Enum.join("?")

    groups =
      groups
      |> List.duplicate(5)
      |> List.flatten()

    {springs, groups}
  end

  def count(springs, groups) do
    {:ok, _pid} = Cache.start_link()

    springs = String.split(springs, "", trim: true)
    count = do_count(springs, groups, 0)

    Cache.stop()
    count
  end

  defp do_count_cache(springs, groups, group_len) do
    key = {springs, groups, group_len}
    case Cache.get(key) do
      nil ->
        sol = do_count(springs, groups, group_len)
        Cache.set(key, sol)
        sol
      sol -> sol
    end
  end

  defp do_count([], [group_len], group_len), do: 1

  defp do_count([], [], 0), do: 1

  defp do_count([], _, _), do: 0

  defp do_count(["#" | springs], groups, group_len) do
    do_count_cache(springs, groups, group_len + 1)
  end

  defp do_count(["." | springs], groups, 0) do
    do_count_cache(springs, groups, 0)
  end

  defp do_count(["." | springs], [group_len | groups], group_len) do
    do_count_cache(springs, groups, 0)
  end

  defp do_count(["." | _springs], _, _), do: 0

  defp do_count(["?" | springs], groups, group_len) do
    solutions_1 = do_count_cache(["#" | springs], groups, group_len)
    solutions_2 = do_count_cache(["." | springs], groups, group_len)
    solutions_1 + solutions_2
  end

end

defmodule Aoc2023.Day12.Part1 do
  import Aoc2023.Day12

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(fn {springs, groups} -> count(springs, groups) end)
    |> Enum.sum()
  end

end

defmodule Aoc2023.Day12.Part2 do
  import Aoc2023.Day12

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&unfold/1)
    |> Enum.map(fn {springs, groups} -> count(springs, groups) end)
    |> Enum.sum()
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day12.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day12.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

