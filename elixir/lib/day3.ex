#------------------------------------------------------------------------------
# Day Three
#
# All claims have an ID and consist of a single rectangle with edges parallel
# to the edges of the fabric. Each claim's rectangle is defined as follows:
#
#     - The number of inches between the left edge of the fabric and the left
#     edge of the rectangle.
#     - The number of inches between the top edge of the fabric and the top edge
#     of the rectangle.
#     - The width of the rectangle in inches.
#     - The height of the rectangle in inches.
#
# A claim like `#123 @ 3,2: 5x4` means that claim ID 123 specifies a rectangle
# 3 inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4
# inches tall. Visually, it claims the square inches of fabric represented by #
# (and ignores the square inches of fabric represented by .) in the diagram
# below:
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day3 do
  @input "data/day3.input"
    |> File.read!
    |> String.trim
    |> String.split("\n")

  def input, do: @input |> Enum.map(&parse_input_to_claim/1)

  defp parse_input_to_claim(claim) do
    delimeters = ["#", " @ ", ": ", ", "]
    [id, startPos, dimens] = String.split(claim, delimeters, trim: true)
    [x, y] = String.split(startPos, ",") |> Enum.map(&String.to_integer/1)
    [w, h] = String.split(dimens, "x") |> Enum.map(&String.to_integer/1)
    {id, {x, y}, {w, h}}
  end

  # Creates a Map that maps an {x,y} point to the list of claim ID's that
  # overlap with it
  def create_grid_from_claims(claims) do
    claims |> Enum.reduce(Map.new(), &add_claim_to_grid/2)
  end

  # Adds each of a claims points the a grid
  def add_claim_to_grid(claim, grid) do
    {id, _, _} = claim

    claim
    |> get_points_in_claim
    |> Enum.reduce(grid, fn point, acc ->
      existing_claims = Map.get(acc, point, [])
      Map.put(acc, point, [id | existing_claims])
    end)
  end

  # Expands claim to a list of its individual points
  def get_points_in_claim({_id, {x1, y1}, {w, h}}) do
    x2 = x1 + w - 1
    y2 = y1 + h - 1
    for x <- x1..x2, y <- y1..y2, do: {x, y}
  end
end

#------------------------------------------------------------------------------
# Part One
#
# How many square inches of fabric are within two or more claims?
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day3.Part1 do
  import AdventOfCode2018.Day3

  def find_overlapping_points(grid) do
    grid |> Enum.filter(fn {_point, ids} -> length(ids) > 1 end)
  end

  def solve do
    input()
    |> create_grid_from_claims
    |> find_overlapping_points
    |> Enum.count
  end
end

#------------------------------------------------------------------------------
# Part Two
#
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day3.Part2 do
  import AdventOfCode2018.Day3

  # Maps a claim ID to a set of its 'neighbors' (other claim IDs that share at
  # least one overlapping point)
  def find_claim_neighbors(grid) do
    Enum.reduce(grid, %{}, fn {_point, claim_ids}, neighbors_map ->
      # These are all of the claim_ids that overlap at this point
      these_neighbors = MapSet.new(claim_ids)

      # For each claim ID that overlaps at this point, add a neighbors entry
      # for that claim that contains the other claims
      Enum.reduce(claim_ids, neighbors_map, fn id, neighbors_map ->
        existing_neighbors = Map.get(neighbors_map, id, MapSet.new())
        new_neighbors = MapSet.union(existing_neighbors, these_neighbors)
        Map.put(neighbors_map, id, new_neighbors)
      end)
    end)
  end

  # Finds a claim where it is its only neighbor
  def find_lonely_claims(claim_neighbors) do
    claim_neighbors
    |> Enum.filter(fn {_id, neighbors} -> MapSet.size(neighbors) === 1 end)
  end

  def solve do
    input()
    |> create_grid_from_claims
    |> find_claim_neighbors
    |> find_lonely_claims
  end
end
