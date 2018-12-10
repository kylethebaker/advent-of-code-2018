#------------------------------------------------------------------------------
# Day One
#
# For example, if the device displays frequency changes of +1, -2, +3, +1, then
# starting from a frequency of zero, the following changes would occur:
#
#     Current frequency  0, change of +1; resulting frequency  1.
#     Current frequency  1, change of -2; resulting frequency -1.
#     Current frequency -1, change of +3; resulting frequency  2.
#     Current frequency  2, change of +1; resulting frequency  3.
#
# In this example, the resulting frequency is 3.
#
# Here are other example situations:
#
#     +1, +1, +1 results in  3
#     +1, +1, -2 results in  0
#     -1, -2, -3 results in -6
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day1 do
  @input "data/day1.input"
    |> File.read!
    |> String.trim
    |> String.split
    |> Enum.map(&String.to_integer/1)

  def input, do: @input
end

#------------------------------------------------------------------------------
# Part One
#
# Starting with a frequency of zero, what is the resulting frequency after all
# of the changes in frequency have been applied?
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day1.Part1 do
  import AdventOfCode2018.Day1

  def solve, do: input() |> Enum.reduce(0, &(&1 + &2))
end

#------------------------------------------------------------------------------
# Part Two
#
# You notice that the device repeats the same frequency change list over and
# over. To calibrate the device, you need to find the first frequency it
# reaches twice.
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day1.Part2 do
  import AdventOfCode2018.Day1

  defp reducer(x, {freqs, total}) do
    new_total = x + total

    if MapSet.member?(freqs, new_total) do
      {:halt, {freqs, new_total}}
    else
      {:cont, {MapSet.put(freqs, new_total), new_total}}
    end
  end

  def solve do
    input()
    |> Stream.cycle
    |> Enum.reduce_while({MapSet.new(), 0}, &reducer/2)
    |> elem(1)
  end
end
