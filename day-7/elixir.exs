#!/usr/bin/env elixir
defmodule Aoc2022.Day7 do
  def part1 do
    {filesystem, _} = 
      "./input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, []}, &execute/2)

    filesystem
    |> Enum.flat_map(&build_parent_size/1) 
    |> Enum.group_by(fn {path, _} -> path end, fn {_, size} -> size end)
    |> Enum.map(fn {path, sizes} -> Enum.sum(sizes) end)
    |> Enum.filter(fn size -> size <= 100000 end)
    |> Enum.sum()
  end

  def part2 do
    {filesystem, _} = 
      "./input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.reduce({%{}, []}, &execute/2)

    filesystem =
      filesystem
      |> Enum.flat_map(&build_parent_size/1) 
      |> Enum.group_by(fn {path, _} -> path end, fn {_, size} -> size end)
      |> Enum.map(fn {path, sizes} -> {path, Enum.sum(sizes)} end)

    used_space =
      filesystem 
      |> Enum.into(%{})
      |> Map.get("/")
    total_space = 70000000
    free_space = total_space - used_space
    needed_space = 30000000 - free_space

    filesystem
    |> Enum.sort_by(fn {_path, size} -> size end)
    |> Enum.find(fn {_path, size} -> size > needed_space end)
    |> case do {_path, size} -> size end
  end

  defp build_parent_size({nil, _size}), do: []

  defp build_parent_size({path, size} = a) do
    [a | build_parent_size({parent(path), size})]
  end

  defp execute("$ cd /", {filesystem, path}) do
    {filesystem, []}
  end

  defp execute("$ cd ..", {filesystem, [_cwd | path]}) do
    {filesystem, path}
  end

  defp execute("$ cd " <> dirname, {filesystem, path}) do
    {filesystem, [dirname | path]}
  end

  defp execute("dir " <> dirname, acc), do: acc

  defp execute("$ ls", acc), do: acc

  defp execute(line, {filesystem, path}) do
    regex = ~r/(?<size>\d+) (?<name>.+)/
    case Regex.named_captures(regex, line) do
      %{"size" => size, "name" => filename} ->
        dir_path = build_path(path)
        dir_size = Map.get(filesystem, dir_path, 0)
        new_size = dir_size + String.to_integer(size)
        filesystem = Map.put(filesystem, dir_path, new_size)
        {filesystem, path}
    end
  end

  defp execute(_, acc), do: acc

  defp parent("/"), do: nil

  defp parent(path) do
    path 
    |> String.split("/") 
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
    |> Enum.join("/")
    |> case do
      "" -> "/"
      otherwise -> otherwise
    end
  end

  defp build_path(path) do
    rel_path = 
      path
      |> Enum.reverse()
      |> Enum.join("/")
    "/#{rel_path}"
  end

end

defmodule Aoc2022.Day7.Part2 do
end

IO.puts("Total sum of size (part 1): #{Aoc2022.Day7.part1()}")
IO.puts("Size of the directory to be deleted (part 2): #{Aoc2022.Day7.part2()}")

