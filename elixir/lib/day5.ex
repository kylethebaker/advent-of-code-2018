#------------------------------------------------------------------------------
# Day Five
#
# The polymer is formed by smaller units which, when triggered, react with each
# other such that two adjacent units of the same type and opposite polarity are
# destroyed. Units' types are represented by letters; units' polarity is
# represented by capitalization. For instance, r and R are units with the same
# type but opposite polarity, whereas r and s are entirely different types and
# do not react.
#
# For example:
#
#   - In aA, a and A react, leaving nothing behind.
#   - In abBA, bB destroys itself, leaving aA. As above, this then destroys
#   itself, leaving nothing.
#   - In abAB, no two adjacent units are of the same type, and so nothing
#   happens.
#   - In aabAAB, even though aa and AA are of the same type, their polarities
#   match, and so nothing happens.
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day5 do
  @input "data/day5.input"
    |> File.read!
    |> String.trim
    |> String.graphemes

    #@input "dabAcCaCBAcCcaDA" |> String.graphemes

  def input do
    @input |> Enum.map(&parse_polymer/1)
  end

  defp to_polarity(x) do
    if String.upcase(x) === x, do: :+, else: :-
  end

  defp to_unit(x) do
    x |> String.upcase |> String.to_atom
  end

  defp parse_polymer(x) do
    {to_unit(x), to_polarity(x)}
  end

  defp is_reaction({u, :+}, {u, :-}), do: true
  defp is_reaction({u, :-}, {u, :+}), do: true
  defp is_reaction(_, _), do: false

  def react_all(polymers) do
    {count, result} = single_pass(polymers)
    if count !== 0 do
      react_all(result)
    else
      result
    end
  end

  defp single_pass(polymers) do
    {prev, count, result} = Enum.reduce(polymers, {nil, 0, []}, &reaction_reducer/2)
    {count, Enum.reverse([prev | result])}
  end

  # Tries to react the previous polymer with the current, keeping track of the
  # number of total reactions and the resulting polymer after a reaction takes
  # place
  defp reaction_reducer(polymer, {nil, count, result}) do
    {polymer, count, result}
  end
  defp reaction_reducer(polymer, {prev_polymer, count, result}) do
    if is_reaction(polymer, prev_polymer) do
      {nil, count + 1, result}
    else
      {polymer, count, [prev_polymer | result]}
    end
  end
end

#------------------------------------------------------------------------------
# Part One
#
# How many units remain after fully reacting the polymer you scanned?
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day5.Part1 do
  import AdventOfCode2018.Day5

  def solve do
    input()
    |> react_all
    |> Enum.count
  end
end

#------------------------------------------------------------------------------
# Part Two
#
# What is the length of the shortest polymer you can produce by removing all
# units of exactly one type and fully reacting the result?
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day5.Part2 do
  import AdventOfCode2018.Day5

  defp find_unique_types(polymers) do
    polymers
    |> Enum.map(fn {x, _} -> x end)
    |> Enum.uniq
  end

  defp count_without_type(polymers, reject_type) do
    polymers
    |> Enum.reject(fn {type, _} -> type === reject_type end)
    |> react_all
    |> Enum.count
  end

  def solve do
    input()
    |> find_unique_types
    |> Enum.map(fn type -> {type, count_without_type(input(), type)} end)
    |> Enum.min_by(fn {_, count} -> count end)
  end
end
