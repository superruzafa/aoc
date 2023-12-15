defmodule Aoc2023.Day15.Operation do
  defstruct [
    :raw,
    :label,
    :op,
    :focal_length
  ]

  def parse(operation) do
    matches =
      ~r/^(?<label>\w+)(?<op>[\-=])(?<flen>\d*)/
      |> Regex.named_captures(operation)

    %__MODULE__{
      raw: operation,
      label: matches["label"],
      op: matches["op"],
      focal_length: parse_focal_length(matches["flen"])
    }
  end

  defp parse_focal_length(""), do: nil

  defp parse_focal_length(string) do
    {int, _} = Integer.parse(string)
    int
  end
end

defmodule Aoc2023.Day15.Box do
  defstruct [
    id: nil,
    lens: Keyword.new()
  ]

  def new(id) do
    %__MODULE__{
      id: id,
      lens: Keyword.new()
    }
  end

  def remove(%__MODULE__{} = box, label) do
    label = String.to_atom(label)
    lens = Keyword.drop(box.lens, [label])
    %{box | lens: lens}
  end

  def replace(%__MODULE__{} = box, label, focal_length) do
    label = String.to_atom(label)
    lens = Keyword.update(box.lens, label, focal_length, fn _ -> focal_length end)
    %{box | lens: lens}
  end

  def focusing_power(%__MODULE__{} = box) do
    box_power = (box.id + 1) 

    box.lens
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_label, focal_length}, slot_nr}, acc ->
      acc + box_power * focal_length * slot_nr
    end)
  end

end

defmodule Aoc2023.Day15.Hashmap do
  alias Aoc2023.Day15.Box

  defstruct [
    boxes: %{}
  ]

  def new do
    %__MODULE__{}
  end

  def replace(%__MODULE__{} = hashmap, box_id, label, focal_length) do
    box = hashmap
          |> get_or_create_box(box_id)
          |> Box.replace(label, focal_length)

    boxes = Map.put(hashmap.boxes, box_id, box)
    %{hashmap | boxes: boxes}
  end

  def remove(%__MODULE__{} = hashmap, box_id, label) do
    box = hashmap
          |> get_or_create_box(box_id)
          |> Box.remove(label)

    boxes = Map.put(hashmap.boxes, box_id, box)
    %{hashmap | boxes: boxes}
  end

  defp get_or_create_box(%__MODULE__{} = hashmap, box_id) do
    Map.get_lazy(hashmap.boxes, box_id, fn -> Box.new(box_id) end)
  end

  def focusing_power(%__MODULE__{} = hashmap) do
    hashmap.boxes
    |> Enum.reduce(0, fn {_box_id, box}, acc ->
      acc + Box.focusing_power(box)
    end)
  end
end

defmodule Aoc2023.Day15 do
  alias Aoc2023.Day15.Operation

  def parse_input(input) do
    input
    |> File.read!()
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Operation.parse/1)
  end

  def hash(string) do
    string
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc ->
      acc
      |> Kernel.+(char)
      |> Kernel.*(17)
      |> rem(256)
    end)

  end

end

defmodule Aoc2023.Day15.Part1 do
  import Aoc2023.Day15

  def run(input) do
    input
    |> parse_input()
    |> Enum.map(&hash(&1.raw))
    |> Enum.sum()
  end

end

defmodule Aoc2023.Day15.Part2 do
  alias Aoc2023.Day15.Hashmap

  import Aoc2023.Day15

  def run(input) do
    input 
    |> parse_input()
    |> process(Hashmap.new())
    |> Hashmap.focusing_power()
  end

  defp process([], %Hashmap{} = hashmap), do: hashmap

  defp process([%{op: "-"} = op | ops], %Hashmap{} = hashmap) do
    box_id = hash(op.label)
    hashmap = Hashmap.remove(hashmap, box_id, op.label)
    process(ops, hashmap)
  end

  defp process([%{op: "="} = op | ops], %Hashmap{} = hashmap) do
    box_id = hash(op.label)
    hashmap = Hashmap.replace(hashmap, box_id, op.label, op.focal_length)
    process(ops, hashmap)
  end

end

case System.argv() do
  [input | _tail] ->
    IO.puts("Part 1: #{Aoc2023.Day15.Part1.run(input)}")
    IO.puts("Part 2: #{Aoc2023.Day15.Part2.run(input)}")

  _otherwise ->
    IO.puts("Usage: elixir #{Path.basename(__ENV__.file)} INPUT")
end

