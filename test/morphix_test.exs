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

  test "compactiform will ignore structs" do
    time = DateTime.utc_now()
    test_map = %{
                  "this" => time,
                  "that" => nil,
                  "the" => "other",
                  "how" => %{the: nil, 
                             heck: nil,
                             empty: %{empty: %{empty: %{}},
                                      blank: nil,
                                      empte: %{sort: %{}, of: nil}}},
                  "but" => %{what: %{},
                             about: "this",
                             deeper: %{nested: "map",
                                       that: %{},
                                       maps: %{ very: "deep", indeed: nil},
                                       time: time
                                     }
                             }
                }
    expected_map = %{
                      "the" => "other",
                      "this" => time,
                      "but" => %{about: "this",
                                 deeper: %{nested: "map",
                                           maps: %{very: "deep"},
                                           time: time
                                         }
                                }

                   }
    assert Morphix.compactiform(test_map) == {:ok, expected_map}
  end
end
