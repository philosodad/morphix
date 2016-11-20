defmodule Morphix do
  @doc """
  Takes a map and returns a flattened version of that map. If the map has nested maps (or the maps nested maps have nested maps, etc.) morphiflat moves all nested key/value pairs to the top level, discarding the original keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat %{this: %{nested: :map, inner: %{twonested: :map, is: "now flat"}}}
  {:ok, %{nested: :map, twonested: :map, is: "now flat"}}

  ```

  In the example, the key `:this` is discarded, along with the key `inner`, because they both point to map values.
  """
  def morphiflat( map ) when is_map map do
    {:ok, flattn map}
  end


  @doc """

  Takes a map as an argument and returns the same map with string keys converted to atom keys. Does not examine nested maps.

  ### Examples

  ```
  iex> Morphix.atomorphify(%{"this" => "map", "has" => %{"string" => "keys"}})
  {:ok, %{this: "map", has: %{"string" => "keys"}}}

  iex> Morphix.atomorphify(%{1 => "2", "1" => 2, "one" => :two})
  {:ok, %{1 => "2", "1": 2, one: :two}}

  iex> Morphix.atomorphify(%{"a" => "2", :a => 2, 'a'  => :two})
  {:ok, %{:a => 2, 'a' => :two }}

  ```
  """
  def atomorphify(map) when is_map map do
    {:ok, atomog map}
  end

  @doc """
  Takes a map as an argument and returns the same map, with all string keys (including keys in nested maps) converted to atom keys.

  ### Examples:

  ```
  iex> Morphix.atomorphiform(%{:this => %{map: %{"has" => "a", :nested => "string", :for =>  %{a: :key}}}, "the" =>  %{"other" => %{map: :does}}, as: "well"})
  {:ok,%{this: %{map: %{has: "a", nested: "string", for: %{a: :key}}}, the: %{other: %{map: :does}}, as: "well"} }

  iex> Morphix.atomorphiform(%{"this" => ["map", %{"has" => ["a", "list"]}], "inside" => "it"})
  {:ok, %{this: ["map", %{has: ["a", "list"]}], inside: "it"}}

  ```
  """
  def atomorphiform(map) do
    {:ok, depth_atomog(map)}
  end

  defp process_list_item(item) do
    cond do
      is_map item -> depth_atomog(item)
      is_list item -> Enum.map(item, fn(x) -> process_list_item(x) end)
      true -> item
    end
  end

  defp depth_atomog (map) do
    atomkeys = fn({k, v}, acc) -> 
      cond do
        is_map v ->
          Map.put_new(acc, atomize_binary(k), depth_atomog(v))
        is_list v ->
          Map.put_new(acc, atomize_binary(k), process_list_item(v))
        true ->
          Map.put_new(acc, atomize_binary(k), v)
      end
    end
    Enum.reduce(map, %{}, atomkeys)
  end

  defp atomog (map) do
    atomkeys = fn({k, v}, acc) ->
      Map.put_new(acc, atomize_binary(k), v)
    end
    Enum.reduce(map, %{}, atomkeys)
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
