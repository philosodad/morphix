defmodule Morphix do
  @moduledoc """
  Morphix provides convenience methods for dealing with Maps, Lists, and Tuples.

  `morphiflat` and `morphiflat!` flatten maps, discarding top level keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat %{flatten: %{this: "map"}, if: "you please"}
  {:ok, %{this: "map", if: "you please"}}


  iex> Morphix.morphiflat! %{flatten: %{this: "map"}, o: "k"}
  %{this: "map", o: "k"}

  ```

  `morphify!` and `morphify` will take either a List or a Tuple as the first argument, and a function as the second. Returns a map, with the keys of the map being the function applied to each member of the input.

  ### Examples:

  ```
  iex> Morphix.morphify!({[1,2,3], [12], [1,2,3,4]}, &length/1)
  %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}

  ```

  `atomorphify` and `atomorphiform` take a map as an input and return the map with all string keys converted to atoms. `atomorphiform` is recursive.
  ### Examples:

  ```
  iex> Morphix.atomorphify(%{"a" => "2", :a => 2, 'a'  => :two})
  {:ok, %{:a => 2, 'a' => :two }}

  ```
  """

  @spec morphiflat(Map.t) :: {:ok | :error, Map.t | String}
  @spec morphiflat!(Map.t) :: Map.t
  @spec morphify(List.t, Function) :: {:ok|:error, Map.t | String}
  @spec morphify(Tuple.t, Function) :: {:ok|:error, Map.t | String}
  @spec morphify!(List.t, Function) :: Map.t
  @spec morphify!(Tuple.t, Function) :: Map.t
  @spec atomorphify(Map.t) :: {:ok, Map.t}
  @spec atomorphiform(Map.t) :: {:ok, Map.t}

  @doc """
  Takes a map and returns a flattend version of that map, discarding any nested keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat! %{you: "will", youwill: %{be: "discarded"}}
  %{you: "will", be: "discarded"}

  ```
  """
  def morphiflat! map do
    flattn map
  end

  @doc """
  Takes a map and returns a flattened version of that map. If the map has nested maps (or the maps nested maps have nested maps, etc.) morphiflat moves all nested key/value pairs to the top level, discarding the original keys.

  ### Examples:

  ```
  iex> Morphix.morphiflat %{this: %{nested: :map, inner: %{twonested: :map, is: "now flat"}}}
  {:ok, %{nested: :map, twonested: :map, is: "now flat"}}

  ```

  In the example, the key `:this` is discarded, along with the key `inner`, because they both point to map values.

  Will return `{:error, <input> is not a Map}` if the input is not a map.

  ### Examples:
  ```
  iex> Morphix.morphiflat({1,2,3})
  {:error, "{1, 2, 3} is not a Map"}

  ```
  """
  def morphiflat(map) when is_map map do
    try do
      {:ok, flattn map}
    rescue
      exception -> {:error, Exception.message(exception)}
    end
  end
  def morphiflat(not_map), do: {:error, "#{inspect(not_map)} is not a Map"}

  defp flattn map do
    not_maps = fn({k, v}, acc) ->
      case is_map v do
        false -> Map.put_new(acc, k, v)
        true -> Map.merge(acc, flattn(v))
      end
    end
    Enum.reduce(map, %{}, not_maps)
  end

  @doc """

  Takes a map as an argument and returns the same map with string keys converted to atom keys. Does not examine nested maps.

  ### Examples

  ```
  iex> Morphix.atomorphify(%{"this" => "map", "has" => %{"string" => "keys"}})
  {:ok, %{this: "map", has: %{"string" => "keys"}}}

  iex> Morphix.atomorphify(%{1 => "2", "1" => 2, "one" => :two})
  {:ok, %{1 => "2", "1": 2, one: :two}}

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
  def atomorphiform(map) when is_map map do
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
    if is_binary(value) do
      try do
        String.to_existing_atom(value)
      rescue
        ArgumentError -> String.to_atom(value)
      end
    else
      value
    end
  end

  @doc """
  Takes a List and a function as arguments and returns `{:ok, Map}`, with the keys of the map the result of applying the function to each item in the list.

  If the function cannot be applied, will return `{:error, message}`

  ### Examples
  ```
  iex> Morphix.morphify([[1,2,3], [12], [1,2,3,4]], &Enum.count/1)
  {:ok, %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}}


  iex> Morphix.morphify({[1,2,3], [12], [1,2,3,4]}, &length/1)
  {:ok, %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}}

  iex> Morphix.morphify([1,2], &String.length/1)
  {:error, "Unable to apply &String.length/1 to each of [1, 2]"}

  ```
  """
  def morphify(enum, funct) when is_tuple(enum), do: morphify(Tuple.to_list(enum), funct)

  def morphify(enum, funct) do
    try do
      {:ok, morphify!(enum, funct)}
    rescue
      _ -> {:error, "Unable to apply #{inspect(funct)} to each of #{inspect(enum)}"}
    end
  end

  @doc """
  Takes a list and a function as arguments and returns a Map, with the keys of the map the result of applying the function to each item in the list.

  ### Examples
  ```
  iex> Morphix.morphify!([[1,2,3], [12], [1,2,3,4]], &Enum.count/1)
  %{1 => [12], 3 => [1,2,3], 4 => [1,2,3,4]}

  ```
  """
  def morphify!(enum, funct) when is_tuple(enum), do: morphify!(Tuple.to_list(enum), funct)
  def morphify!(enum, funct) do
    Enum.reduce(enum,
    %{},
    fn(x, acc) -> Map.put(acc, funct.(x), x) end)
  end

end
