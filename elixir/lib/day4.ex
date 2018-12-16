#------------------------------------------------------------------------------
# Day Four
#
# For the past few months secretly observing this guard post! They've been
# writing down the ID of the one guard on duty that night - the Elves seem to
# have decided that one guard was enough for the overnight shift - as well as
# when they fall asleep or wake up while at their post (your puzzle input).
#
# Timestamps are written using year-month-day hour:minute format. The guard
# falling asleep or waking up is always the one whose shift most recently
# started. Because all asleep/awake times are during the midnight hour (00:00 -
# 00:59), only the minute portion (00 - 59) is relevant for those events.
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day4 do
  @input "data/day4.input"
    |> File.read!
    |> String.trim
    |> String.split("\n")

  def input do
    @input
    |> Enum.map(&parse_entry/1)
    |> sort_entries
    |> add_guard_context
    |> Enum.reverse
  end

  defp parse_entry(entry) do
    [time, log] = String.split(entry, ["[", "] "], trim: true)
    {parse_time(time), parse_log(log)}
  end

  defp parse_time(time) do
    time_components = String.split(time, ["-", " ", ":"])
    timestamp = create_timestamp(time_components)
    [_y, mo, d, h, m] = Enum.map(time_components, &String.to_integer/1)

    %{month: mo, day: d, hour: h, minute: m, timestamp: timestamp}
  end

  # Creates a single numeric time component to make sorting easier
  defp create_timestamp(time_components) do
    time_components
    |> Enum.map(fn x -> String.pad_leading(x, 2, "0") end)
    |> Enum.join
    |> String.to_integer
  end

  # Parses log entry to either `{:begins, guard_id}`, `{:wakes}`, `{:sleeps}`
  defp parse_log("Guard #" <> rest) do
    [guard_number | _rest] = String.split(rest, " ")
    {:begins, String.to_integer(guard_number)}
  end
  defp parse_log("wakes up"), do: {:wakes}
  defp parse_log("falls asleep"), do: {:sleeps}

  # Sorts ascending by timestamp
  defp sort_entries(entries) do
    Enum.sort(entries, fn {x, _}, {y, _} ->
      x.timestamp <= y.timestamp
    end)
  end

  # Adds the guard ID to all :sleep/:wake entries so that the guard context
  # will exist on all entries and not just Beings Shift ones
  defp add_guard_context(entries) do
    entries |> Enum.reduce({:nil, []}, &guard_context_reducer/2) |> elem(1)
  end
  defp guard_context_reducer({_, {_, guard}} = log, {nil, []}),
    do: {guard, [log]}
  defp guard_context_reducer({_, {:begins, new_guard}} = log, {_, entries}),
    do: {new_guard, [log | entries]}
  defp guard_context_reducer({time, {log_type}}, {current_guard, entries}),
    do: {current_guard, [{time, {log_type, current_guard}} | entries]}

  # Groups the logs entries by the guard ID
  def group_by_guard(logs) do
    Enum.group_by(logs, fn {_, {_, guard}} -> guard end)
  end

  # Generates a list of {start, stop} tuples representing time asleep
  def create_sleep_ranges(logs) do
    Enum.reduce(logs, {nil, []}, fn {time, {action, _}}, {sleep_time, ranges} ->
      case action do
        :sleeps -> {time, ranges}
        :wakes -> {nil, [{sleep_time, time} | ranges]}
        :begins -> {nil, ranges}
      end
    end)
    |> elem(1)
  end

  # Sums all the sleep ranges to get the total minutes asleep
  def total_minutes_asleep(sleep_ranges) do
    sleep_ranges
    |> Enum.map(fn {%{minute: start}, %{minute: stop}} -> stop - start end)
    |> Enum.reduce(0, &(&1 + &2))
  end

  # Maps each minute to the number of times someone was asleep on it
  def asleep_by_minute(sleep_ranges) do
    sleep_ranges
    |> Enum.map(fn {start, stop} -> Enum.to_list(start.minute..stop.minute-1) end)
    |> Enum.reduce(%{}, fn slept_minutes, acc ->
      slept_minutes
      |> Enum.to_list
      |> Enum.reduce(acc, fn minute, already_slept ->
        Map.put(already_slept, minute, Map.get(already_slept, minute, 0) + 1)
      end)
    end)
  end

  # Finds the most slept minute from the log
  def get_most_slept_minute(logs) do
    most_slept =
      logs
      |> create_sleep_ranges
      |> asleep_by_minute

    if map_size(most_slept) != 0 do
      Enum.max_by(most_slept, fn {_, x} -> x end)
    else
      {0, 0}
    end
  end
end

#------------------------------------------------------------------------------
# Part One
#
# Find the guard that has the most minutes asleep. What minute does that guard
# spend asleep the most?
#
# In the example above, Guard #10 spent the most minutes asleep, a total of 50
# minutes (20+25+5), while Guard #99 only slept for a total of 30 minutes
# (10+10+10). Guard #10 was asleep most during minute 24 (on two days, whereas
# any other minute the guard was asleep was only seen on one day).
#
# While this example listed the entries in chronological order, your entries
# are in the order you found them. You'll need to organize them before they can
# be analyzed.
#
# What is the ID of the guard you chose multiplied by the minute you chose?
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day4.Part1 do
  import AdventOfCode2018.Day4

  def get_sleepiest_guard(grouped_guards) do
    grouped_guards
    |> Enum.map(fn {guard, times} -> {guard, create_sleep_ranges(times)} end)
    |> Enum.map(fn {guard, ranges} -> {guard, total_minutes_asleep(ranges)} end)
    |> Enum.max_by(fn {_, x} -> x end)
  end

  def solve do
    grouped = input() |> group_by_guard
    {sleepiest, _} = get_sleepiest_guard(grouped)
    {most_slept, _} = get_most_slept_minute(grouped[sleepiest])
    (sleepiest * most_slept)
  end
end

#------------------------------------------------------------------------------
# Part Two
#
# Of all guards, which guard is most frequently asleep on the same minute?
#
# What is the ID of the guard you chose multiplied by the minute you chose? (In
# the above example, the answer would be 99 * 45 = 4455.)
#------------------------------------------------------------------------------

defmodule AdventOfCode2018.Day4.Part2 do
  import AdventOfCode2018.Day4

  def solve do
    input()
    |> group_by_guard
    |> Enum.map(fn {guard, log} -> {guard, get_most_slept_minute(log)} end)
    |> Enum.max_by(fn {_guard, {_minute, slept}} -> slept end)
    |> (fn {guard_id, {minute, _}} -> guard_id * minute end).()
  end
end
