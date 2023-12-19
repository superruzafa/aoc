defmodule Aoc2023.Day19.Xmas do
  @behaviour Access

  defstruct [x: 0, m: 0, a: 0, s: 0]

  def parse(binary) do
    opts =
      ~r/(?<cat>\w)=(?<rating>\d+)/
      |> Regex.scan(binary)
      |> Enum.map(fn [_, cat, rating] ->
        {String.to_atom(cat), as_integer(rating)}
      end)

    struct(__MODULE__, opts)
  end

  def new(opts \\ []), do: struct(__MODULE__, opts)

  def sum(%__MODULE__{} = xmas) do
    xmas.x + xmas.m + xmas.a + xmas.s
  end

  def fetch(%__MODULE__{} = xmas, cat) do
    Map.fetch(xmas, cat)
  end

  def get_and_update(_data, _key, _function), do: :not_implemented
  def pop(_data, _key), do: :not_implemented

  defp as_integer(string) do
    {int, _} = Integer.parse(string)
    int
  end

end

defmodule Aoc2023.Day19.Workflow do
  alias Aoc2023.Day19.Xmas

  defstruct [
    name: nil,
    rules: []
  ]

  @regex ~r/^(?<name>\w+)\{(?<rules>[^}]+)\}/

  def parse(line) do
    matches = Regex.named_captures(@regex, line)
    name = matches["name"]

    rules =
      matches["rules"]
      |> String.split(",")
      |> Enum.map(&parse_rule/1)

    %__MODULE__{
      name: name,
      rules: rules
    }
  end

  defp parse_rule(binary) do
    [
      &parse_less_than_rule/1,
      &parse_greater_than_rule/1,
      &parse_inconditional_rule/1,
    ]
    |> Enum.find_value(& &1.(binary))
  end

  @regex_less_than ~r/^(?<cat>\w+)\<(?<rating>\d+)\:(?<wf_name>\w+)/

  defp parse_less_than_rule(rule) do
    case Regex.named_captures(@regex_less_than, rule) do
      nil ->
        nil

      matches ->
        cat = matches["cat"] |> String.to_atom()
        rating = matches["rating"] |> as_integer()
        next_id = matches["wf_name"] |> parse_workflow_name()

        %{
          cat: cat,
          op: :less_than,
          rating: rating,
          next_id: next_id,
          f: fn %Xmas{} = xmas ->
              if xmas[cat] < rating,
                do: next_id,
                else: false
            end,
        }
    end
  end

  @regex_greater_than ~r/^(?<cat>\w+)\>(?<rating>\d+)\:(?<wf_name>\w+)/

  defp parse_greater_than_rule(rule) do
    case Regex.named_captures(@regex_greater_than, rule) do
      nil ->
        nil

      matches ->
        cat = matches["cat"] |> String.to_atom()
        rating = matches["rating"] |> as_integer()
        next_id = matches["wf_name"] |> parse_workflow_name()

        %{
          cat: cat,
          op: :greater_than,
          rating: rating,
          next_id: next_id,
          f: fn %Xmas{} = xmas ->
              if xmas[cat] > rating,
                do: next_id,
                else: false
            end
        }
    end
  end

  defp parse_inconditional_rule(rule) do
    next_id = parse_workflow_name(rule)
    %{
      op: :inconditional,
      next_id: next_id,
      f: fn _rule -> next_id end
    }
  end

  defp parse_workflow_name("A"), do: :accept
  defp parse_workflow_name("R"), do: :reject
  defp parse_workflow_name(wf_name), do: wf_name

  defp as_integer(string) do
    {int, _} = Integer.parse(string)
    int
  end

end

defmodule Aoc2023.Day19 do
  alias __MODULE__.{Workflow, Xmas}

  def parse_input(input) do
    [workflows, xmas] =
      input
      |> File.read!()
      |> String.split("\n\n")

    workflows =
      workflows
      |> String.split("\n", trim: true)
      |> Enum.map(&Workflow.parse/1)
      |> Enum.map(fn %{name: name} = wf -> {name, wf} end)
      |> Map.new()

    xmas =
      xmas
      |> String.split("\n", trim: true)
      |> Enum.map(&Xmas.parse/1)

    [workflows, xmas]
  end

end

defmodule Aoc2023.Day19.Part1 do
  alias Aoc2023.Day19.Xmas

  import Aoc2023.Day19

  def run(input) do
    [workflows, xmas] = parse_input(input)

    xmas
    |> Enum.filter(&accepted?(&1, workflows))
    |> Enum.map(&Xmas.sum/1)
    |> Enum.sum()
  end

  defp accepted?(%Xmas{} = xmas, workflows, workflow_id \\ "in") do
    workflows
    |> Map.fetch!(workflow_id)
    |> Map.fetch!(:rules)
    |> Enum.find_value(fn rule -> rule.f.(xmas) end)
    |> case do
      :accept -> true
      :reject -> false
      workflow_id -> accepted?(xmas, workflows, workflow_id)
    end

  end

end

defmodule Aoc2023.Day19.Part2 do
  import Aoc2023.Day19

  def run(input) do
    [workflows, _parts] =
      input
      |> parse_input()

    r = 1..4000

    count_accepted(%{x: r, m: r, a: r, s: r}, workflows, "in")
  end

  defp count_accepted(_xmas, _workflows, :reject), do: 0

  defp count_accepted(xmas, _workflows, :accept) do
    [xmas.x, xmas.m, xmas.a, xmas.s]
    |> Enum.map(&Range.size/1)
    |> Enum.product()
  end

  defp count_accepted(xmas, workflows, wf_id) do
    workflow = workflows[wf_id]
    split_count(xmas, workflows, workflow.rules)
  end

  defp split_count(xmas, workflows, [id]) do
    count_accepted(xmas, workflows, id.next_id)
  end

  defp split_count(xmas, workflows, [%{op: :inconditional} = rule | _rules]) do
    count_accepted(xmas, workflows, rule.next_id)
  end

  defp split_count(xmas, workflows, [%{op: :less_than} = rule | rules]) do
    start.._ = xmas[rule.cat]
    {left, right} = xmas[rule.cat] |> Range.split(rule.rating - start)

    accepted_left =
      xmas
      |> Map.put(rule.cat, left)
      |> count_accepted(workflows, rule.next_id)

    accepted_right =
      xmas
      |> Map.put(rule.cat, right)
      |> split_count(workflows, rules)

    accepted_left + accepted_right
  end

  defp split_count(xmas, workflows, [%{op: :greater_than} = rule | rules]) do
    start.._ = xmas[rule.cat]
    {left, right} = xmas[rule.cat] |> Range.split(rule.rating - start + 1)

    accepted_left =
      xmas
      |> Map.put(rule.cat, left)
      |> split_count(workflows, rules)

    accepted_right =
      xmas
      |> Map.put(rule.cat, right)
      |> count_accepted(workflows, rule.next_id)

    accepted_left + accepted_right
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day19.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day19.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

