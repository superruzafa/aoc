defmodule Aoc2023.Day8.Map do
  defstruct [
    :moves,
    :network
  ]

  def parse_input(input) do
    [moves | network] =
      input
      |> File.read!()
      |> String.split("\n", trim: true)

    %__MODULE__{
      moves: parse_instructions(moves),
      network: parse_network(network)
    }
  end

  defp parse_instructions(moves) do
    moves
    |> String.split("", trim: true)
    |> Enum.map(fn
      "R" -> :right
      "L" -> :left
    end)
  end

  defp parse_network(network) do
    network
    |> Enum.map(&parse_node/1)
    |> Map.new()
  end

  @node_regex ~r/((?<source>\w{3}) = \((?<left>\w{3}), (?<right>\w{3})\))/
  defp parse_node(node) do
    matches = Regex.named_captures(@node_regex, node)
    {matches["source"], %{left: matches["left"], right: matches["right"]}}
  end
end

defmodule Aoc2023.Day8.Part1 do
  alias Aoc2023.Day8.Map

  def run(input) do
    map =
      input
      |> Map.parse_input()

    map.moves
    |> Stream.cycle()
    |> Enum.reduce_while({"AAA", 0}, fn
      _move, {"ZZZ", steps} -> {:halt, steps}
      :left, {node, steps} -> {:cont, {map.network[node].left, steps + 1}}
      :right, {node, steps} -> {:cont, {map.network[node].right, steps + 1}}
    end)
  end

end

defmodule Aoc2023.Day8.Part2 do
  alias Aoc2023.Day8.Map

  def run(input) do
    map = Map.parse_input(input)
    moves = Stream.cycle(map.moves)
    map.network
    |> Elixir.Map.keys()
    |> Enum.filter(&ends_with_a?/1)
    |> Enum.map(fn node ->
      find_iteration_node_z(map.network, node, moves)
    end)
    |> lcm_list()
  end

  defp gcd(a, 0), do: a

  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(a, b),
    do: div(abs(a * b), gcd(a, b))

  defp lcm_list([n]), do: n

  defp lcm_list([head | tail]),
    do: lcm(head, lcm_list(tail))

  defp find_iteration_node_z(network, node, moves) do
    moves
    |> Stream.transform(node, fn move, node ->
      node = network[node][move]
      {[node], node}
    end)
    |> Stream.with_index(1)
    |> Enum.find_value(fn {node, iteration} ->
      if ends_with_z?(node),
        do: iteration,
        else: nil
    end)
  end

  defp ends_with_a?(string),
    do: String.ends_with?(string, "A")

  defp ends_with_z?(nodes) when is_list(nodes),
    do: Enum.all?(nodes, &ends_with_z?/1)

  defp ends_with_z?(string),
    do: String.ends_with?(string, "Z")

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day8.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day8.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end


