defmodule PartiphifyTest do
  use ExUnit.Case
  use PropCheck

  # number of partitions should be correct
  property "number of partitions is correct" do
    forall {list, p} <- {list(), integer(1,10)} do
      # IO.inspect({Enum.count(list), p})
      partitioned = Morphix.partiphify!(list, p)
      Enum.count(partitioned) == p
    end
  end

  # other properties: every item in original list is in partitions
  property "every item in the original list is in a partition" do
    forall {list, p} <- {list(), integer(1,10)} do
      partitioned = Morphix.partiphify!(list, p)
      Enum.reduce(list, true, fn i, acc ->
        in_a_list = Enum.reduce(partitioned, false, fn part, acc ->
          Enum.member?(part, i) || acc
        end)
        in_a_list && acc
      end)
    end
  end
  # the sum of the length of the partitions is the length of the original
  property "the sum of all partition lengths is the length of the original" do
    forall {list, p} <- {list(), integer(1,10)} do
      list
      |> Morphix.partiphify!(p)
      |> Enum.reduce(0, fn part, acc -> Enum.count(part) + acc end)
      |> Kernel.==(Enum.count(list))
    end
  end
  # each partition is +-1 of every other partition
end