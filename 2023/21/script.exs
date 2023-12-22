defmodule Script do
  def my_rem(a, b) when a >=0, do: rem(a, b)
  def my_rem(a, b), do: b + rem(a + 1, b) - 1
end

-20..20
|> Enum.each(fn n ->
  IO.puts("#{n} -> #{Script.my_rem(n, 10)}")
end)

