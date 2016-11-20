defmodule MorphixTest do
  use ExUnit.Case, async: true
  require Morphix
  doctest Morphix

  test "atomorphiform will handle lists of nested maps" do
    test_map = %{
                  "this" =>
                    [
                      %{"map" => "has"},
                      %{"an" => "inner",
                      "list" =>
                        ["of",
                          %{"string" => "key"}
                        ]
                      }
                    ],
                  "maps" => "as well"
                }
    expected_map = %{
                      this:
                        [
                          %{map: "has"},
                          %{an: "inner",
                            list:
                            ["of",
                              %{string: "key"}
                            ]
                          }
                        ],
                      maps: "as well"
                    }
    assert Morphix.atomorphiform(test_map) == {:ok, expected_map}
  end
end
