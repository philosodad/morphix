defmodule PartiphificationTest do
  use ExUnit.Case
  use ExUnitProperties
  #
  # number of partitions should be correct
  property "number of partitions is correct" do
    check all list <- list_of(term(), min_length: 0, max_length: 100),
              part <- integer(1..27) do
      assert list
             |> Morphix.partiphify!(part)
             |> Enum.count()
             |> Kernel.==(part)
    end
  end

  # other properties: every item in original list is in partitions
  property "every item in the original list is in a partition" do
    check all list <- list_of(term(), min_length: 0, max_length: 100),
              part <- integer(1..27) do
      partitioned = Morphix.partiphify!(list, part)
      assert Enum.reduce(list, true, fn list_item, acc ->
               in_a_list =
                 Enum.reduce(partitioned, false, fn partition, acc ->
                   Enum.member?(partition, list_item) || acc
                 end)

               in_a_list && acc
             end)
    end
  end

  # the sum of the length of the partitions is the length of the original
  property "the sum of all partition lengths is the length of the original" do
    check all list <- list_of(term(), min_length: 0, max_length: 100),
              part <- integer(1..27) do
      assert list
      |> Morphix.partiphify!(part)
      |> Enum.map(fn p -> Enum.count(p) end)
      |> Enum.sum()
      |> Kernel.==(Enum.count(list))
    end
  end

  # each partition is +-1 of every other partition
  property "all partition counts are within one of all other partition counts" do
    check all list <- list_of(term(), min_length: 0, max_length: 100),
              part <- integer(1..27) do
      {min, max} =
        list
        |> Morphix.partiphify!(part)
        |> Enum.map(fn p -> Enum.count(p) end)
        |> Enum.min_max()
      assert abs(max - min) <= 1
    end
  end

end
