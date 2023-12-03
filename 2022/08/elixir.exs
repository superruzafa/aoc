#!/usr/bin/env elixir
defmodule Aoc2022.Day8 do
  def part1 do
    forest = build_forest()
    size = forest_size(forest)
    find_visible(forest, size)
  end

  def part2 do
    forest = build_forest()
    size = forest_size(forest)

    best_scenic(forest, size)
  end

  defp best_scenic(forest, size) do
    forest
    |> Enum.map(fn {{row, col}, tree_height} -> 
      [
        viewable_trees_in_direction({row - 1, col}, tree_height, forest, size, &to_top/1),
        viewable_trees_in_direction({row, col + 1}, tree_height, forest, size, &to_right/1),
        viewable_trees_in_direction({row, col - 1}, tree_height, forest, size, &to_left/1),
        viewable_trees_in_direction({row + 1, col}, tree_height, forest, size, &to_bottom/1),
      ]
      |> Enum.product()
    end)
    |> Enum.max()
  end

  defp viewable_trees_in_direction({-1, _}, _tree_height, _forest, _size, _stepper), do: 0
  defp viewable_trees_in_direction({_, -1}, _tree_height, _forest, _size, _stepper), do: 0
  defp viewable_trees_in_direction({row, _}, _tree_height, _forest, {maxrow, _}, _stepper) when maxrow < row, do: 0
  defp viewable_trees_in_direction({_, col}, _tree_height, _forest, {_, maxcol}, _stepper) when maxcol < col, do: 0

  defp viewable_trees_in_direction(pos, tree_height, forest, size, stepper) do
    forest
    |> Map.fetch!(pos)
    |> Kernel.<(tree_height)
    |> case do
      true -> 1 + viewable_trees_in_direction(stepper.(pos), tree_height, forest, size, stepper)
      false -> 1
    end
  end

  defp build_forest() do
    "./input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row_line, row_num}, map ->
      row_to_map(row_line, row_num)
      |> Map.merge(map)
    end)
  end

  defp row_to_map(row_line, row_num) do
    row_line
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {tree_height, col_num}, acc ->
      Map.put(acc, {row_num, col_num}, tree_height)
    end)
  end

  defp forest_size(forest) do
    {
      forest |> Enum.map(fn {{row, _}, _} -> row end) |> Enum.max(),
      forest |> Enum.map(fn {{_, col}, _} -> col end) |> Enum.max()
    }
  end

  defp find_visible(forest, forest_size) do
    Enum.count(forest, fn tree -> is_visible?(tree, forest, forest_size) end)
  end

  defp is_visible?({{0, _}, _tree_height}, _forest, _forest_size), do: true
  defp is_visible?({{_, 0}, _tree_height}, _forest, _forest_size), do: true
  defp is_visible?({{rows, _}, _tree_height}, _forest, {rows, _}), do: true
  defp is_visible?({{_, cols}, _tree_height}, _forest, {_, cols}), do: true

  defp is_visible?({{row, col}, tree_height}, forest, size) do
    [
      is_visible_from_line?({row - 1, col}, tree_height, forest, size, &to_top/1),
      is_visible_from_line?({row + 1, col}, tree_height, forest, size, &to_bottom/1),
      is_visible_from_line?({row, col - 1}, tree_height, forest, size, &to_left/1),
      is_visible_from_line?({row, col + 1}, tree_height, forest, size, &to_right/1)
    ]
    |> Enum.any?()
  end

  defp to_top({row, col}), do: {row - 1, col}
  defp to_bottom({row, col}), do: {row + 1, col}
  defp to_right({row, col}), do: {row, col + 1}
  defp to_left({row, col}), do: {row, col - 1}

  defp is_visible_from_line?({-1, _}, _tree_height, _forest, _size, _stepper), do: true
  defp is_visible_from_line?({_, -1}, _tree_height, _forest, _size, _stepper), do: true
  defp is_visible_from_line?({row, _}, _tree_height, _forest, {maxrow, _}, _stepper) when row > maxrow, do: true
  defp is_visible_from_line?({_, col}, _tree_height, _forest, {_, maxcol}, _stepper) when col > maxcol, do: true

  defp is_visible_from_line?(pos, tree_height, forest, size, stepper) do
    forest
    |> Map.fetch!(pos)
    |> Kernel.<(tree_height)
    |> case do
      true -> is_visible_from_line?(stepper.(pos), tree_height, forest, size, stepper)
      false -> false
    end
  end

end

IO.puts("# visible trees outside the grid (part 1): #{Aoc2022.Day8.part1()}")
IO.puts("Best scenic score (part 2): #{Aoc2022.Day8.part2()}")

