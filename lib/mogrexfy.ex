defmodule Mogrexfy do
  @doc """
  mogriflat(map)

  Flattens a map into another map. If the map has nested maps, then the key to the nested map is discarded and the inner map is also flattened.

  #Examples:
  iex> Mogrexfy.mogriflat %{this: %{nested: :map, inner: %{twonested: :map, is: "now flat"}}}
  {:ok, %{nested: :map, twonested: :map, is: "now flat"}}
  """
  def mogriflat( map ) when is_map map do
    {:ok, flattn map}
  end


  @doc """
  atomogrify(map)

  If the map has string keys, converts them to symbols. Will not alter nested maps and ignores non-string keys, will overwrite duplicates.

  #Examples
  iex> Mogrexfy.atomogrify(%{"this" => "map", "has" => %{"string" => "keys"}})
  {:ok, %{this: "map", has: %{"string" => "keys"}}}

  iex> Mogrexfy.atomogrify(%{1 => "2", "1" => 2, "one" => :two})
  {:ok, %{1 => "2", "1": 2, one: :two}}

  iex> Mogrexfy.atomogrify(%{"a" => "2", :a => 2, 'a'  => :two})
  {:ok, %{:a => 2, 'a' => :two }}
  """
  def atomogrify(map) when is_map map do
    {:ok, atomog map}
  end

  @doc """
  atomogriform(map) 

  converts nested strings to keys at any level.

  Examples:
  iex> Mogrexfy.atomogriform(%{:this => %{map: %{"has" => "a", :nested => "string", :for =>  %{a: :key}}}, "the" =>  %{"other" => %{map: :does}}, as: "well"})
  {:ok,%{this: %{map: %{has: "a", nested: "string", for: %{a: :key}}}, the: %{other: %{map: :does}}, as: "well"} }
  """
  def atomogriform(map) do
    {:ok, depth_atomog(map)}
  end

  defp depth_atomog (map) do
    symkeys = fn({k, v}, acc) -> 
      if is_map v do
        Map.put_new(acc, atomize_binary(k), depth_atomog(v))
      else 
        Map.put_new(acc, atomize_binary(k), v) 
      end
    end
    Enum.reduce(map, %{}, symkeys)
  end

  defp atomog (map) do
    symkeys = fn({k, v}, acc) ->
      Map.put_new(acc, atomize_binary(k), v)
    end
    Enum.reduce(map, %{}, symkeys)
  end

  defp atomize_binary(value) do 
    if is_binary(value), do: String.to_atom(value), else: value
  end

  defp flattn map do
    not_maps = fn({k, v}, acc) -> 
      if !is_map v do
        Map.put_new(acc, k, v)
      else
        Map.merge(acc, flattn(v))
      end
    end
    Enum.reduce(map, %{}, not_maps)
  end 

end
