defmodule PartiphifyTest do
  use ExUnit.Case
  use PropCheck

  # we want a property test that:
  # gets a list and an integer
  # and checks that the function Morphix.partifify!(list l, integer n)
  # returns a list of length n
  # this checks the number of partitions return
  property "number of partitions is correct" do
    forall {list, p} <- {list(), integer(1,50)} do
      partitioned = Morphix.partiphify!(list, p)
      Enum.count(partitioned) == p
    end
  end

  # other properties: every item in original list is in partitions
  # the sum of the length of the partitions is the length of the original
  # each partition is +-1 of every other partition
end