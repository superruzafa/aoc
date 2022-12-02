#!/usr/bin/env elixir
defmodule Aoc2022.Day2.Part1 do
  def run do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.reject(& &1 == "")
    |> Enum.map(&parse_round/1)
    |> Enum.map(fn {opponent_hand, player_hand} ->
      play_round(opponent_hand, player_hand)
    end)
    |> Enum.sum()
  end

  defp parse_round(round) do
    [opponent_hand, player_hand] = String.split(round, " ")
    {parse_opponent_hand(opponent_hand), parse_player_hand(player_hand)}
  end

  defp parse_opponent_hand("A"), do: :rock
  defp parse_opponent_hand("B"), do: :paper
  defp parse_opponent_hand("C"), do: :scissors

  defp parse_player_hand("X"), do: :rock
  defp parse_player_hand("Y"), do: :paper
  defp parse_player_hand("Z"), do: :scissors

  @lose_points 0
  @draw_points 3
  @win_points 6

  defp play_round(opponent_hand, player_hand) do
    case player_result(opponent_hand, player_hand) do
      :draw -> @draw_points + value_of(player_hand)
      :player_wins -> @win_points + value_of(player_hand)
      :opponent_wins -> @lose_points + value_of(player_hand)
    end
  end

  defp player_result(:rock, :rock), do: :draw
  defp player_result(:rock, :paper), do: :player_wins
  defp player_result(:rock, :scissors), do: :opponent_wins

  defp player_result(:scissors, :rock), do: :player_wins
  defp player_result(:scissors, :paper), do: :opponent_wins
  defp player_result(:scissors, :scissors), do: :draw

  defp player_result(:paper, :rock), do: :opponent_wins
  defp player_result(:paper, :paper), do: :draw
  defp player_result(:paper, :scissors), do: :player_wins

  defp value_of(:rock), do: 1
  defp value_of(:paper), do: 2
  defp value_of(:scissors), do: 3

end

defmodule Aoc2022.Day2.Part2 do
  def run do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.reject(& &1 == "")
    |> Enum.map(&parse_round/1)
    |> Enum.map(fn {opponent_hand, player_fate} ->
      play_round(opponent_hand, player_fate)
    end)
    |> Enum.sum()
  end

  defp parse_round(round) do
    [opponent_hand, player_fate] = String.split(round, " ")
    {parse_opponent_hand(opponent_hand), parse_player_fate(player_fate)}
  end

  defp parse_opponent_hand("A"), do: :rock
  defp parse_opponent_hand("B"), do: :paper
  defp parse_opponent_hand("C"), do: :scissors

  defp parse_player_fate("X"), do: :must_lose
  defp parse_player_fate("Y"), do: :must_draw
  defp parse_player_fate("Z"), do: :must_win

  @lose_points 0
  @draw_points 3
  @win_points 6

  defp play_round(opponent_hand, player_fate) do
    case player_fate do
      :must_win -> @win_points + value_of(what_wins_to(opponent_hand))
      :must_draw -> @draw_points + value_of(what_draws(opponent_hand))
      :must_lose -> @lose_points + value_of(what_loses_against(opponent_hand))
    end
  end

  defp what_wins_to(:rock), do: :paper
  defp what_wins_to(:paper), do: :scissors
  defp what_wins_to(:scissors), do: :rock

  defp what_draws(hand), do: hand

  defp what_loses_against(:rock), do: :scissors
  defp what_loses_against(:paper), do: :rock
  defp what_loses_against(:scissors), do: :paper

  defp value_of(:rock), do: 1
  defp value_of(:paper), do: 2
  defp value_of(:scissors), do: 3

end

IO.puts("Player score (part 1): #{Aoc2022.Day2.Part1.run()}")
IO.puts("Player score (part 2): #{Aoc2022.Day2.Part2.run()}")

