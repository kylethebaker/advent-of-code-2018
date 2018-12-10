#------------------------------------------------------------------------------
# Day Two
#
# To make sure you didn't miss any, you scan the likely candidate boxes again,
# counting the number that have an ID containing exactly two of any letter and
# then separately counting those with exactly three of any letter. You can
# multiply those two counts together to get a rudimentary checksum and compare
# it to what your device predicts.
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day2 do
  @input "data/day2.input"
    |> File.read!
    |> String.trim
    |> String.split

  def input, do: @input
end

#------------------------------------------------------------------------------
# Part One
#
# Of these box IDs, four of them contain a letter which appears exactly twice,
# and three of them contain a letter which appears exactly three times.
# Multiplying these together produces a checksum of 4 * 3 = 12.
#
# What is the checksum for your list of box IDs?
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day2.Part1 do
  import AdventOfCode2018.Day2

  defp get_letter_counts(string) do
    string
    |> String.graphemes
    |> Enum.reduce(%{}, fn letter, counts ->
      Map.put(counts, letter, Map.get(counts, letter, 0) + 1)
    end)
  end

  defp has_n_same_letters(counts, n),
    do: Enum.any?(counts, fn {_letter, count } -> count === n end)

  defp has_pair(counts), do: has_n_same_letters(counts, 2)
  defp has_triplet(counts), do: has_n_same_letters(counts, 3)

  defp get_word_checksum(letter_counts) do
    pair = if has_pair(letter_counts), do: 1, else: 0
    triplet = if has_triplet(letter_counts), do: 1, else: 0
    {pair, triplet}
  end

  defp sum_tuples({a1, b1}, {a2, b2}), do: {a1 + a2, b1 + b2}

  def solve do
    input()
    |> Enum.map(&get_letter_counts/1)
    |> Enum.map(&get_word_checksum/1)
    |> Enum.reduce(&sum_tuples/2)
    |> (fn {pairs, triplets} -> pairs * triplets end).()
  end
end

#------------------------------------------------------------------------------
# Part Two
#
# The boxes will have IDs which differ by exactly one character at the same
# position in both strings.
#
# What letters are common between the two correct box IDs? (In the example
# above, this is found by removing the differing character from either ID,
# producing fgij.)
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day2.Part2 do
  import AdventOfCode2018.Day2

  defp remove_mismatched_letters({w1, w2}) do
    [String.graphemes(w1), String.graphemes(w2)]
    |> Enum.zip
    |> Enum.filter(fn {a, b} -> a === b end)
    |> Enum.map(fn pair -> elem(pair, 0) end)
    |> Enum.join
  end

  defp has_single_difference({w1, w2}) do
    differences =
      [String.graphemes(w1), String.graphemes(w2)]
      |> Enum.zip
      |> Enum.map(fn {a, b} -> a === b end)
      |> Enum.filter(fn a -> !a end)
      |> Enum.count

    differences === 1
  end

  defp find_boxes_with_one_difference(input) do
    permutations = for w1 <- input, w2 <- input, do: {w1, w2}

    permutations
    |> Enum.reject(fn {x, y} -> x === y end)
    |> Enum.filter(&has_single_difference/1)
    |> hd
  end

  def solve do
    input()
    |> find_boxes_with_one_difference
    |> remove_mismatched_letters
  end
end
