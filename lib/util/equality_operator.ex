defmodule Util.EqualityOperator do
  @moduledoc """
  The `equalif*` method is designed to allow for unorderd equality comparison between lists. In an ordered comparison, `[1,2,3]` is not considered equal to `[3,2,1]`, but `equali/fy?|form?` would consider those two lists to be equal. 

  `equalify|equaliform?` will accept inputs other than maps, tuples, or lists:

  ###Examples:

  ```
  iex> Morphix.equaliform?(1,1)
  true

  iex> Morphix.equaliform?(DateTime.utc_now(), DateTime.utc_now())
  false

  ```

  But it is designed for situations where you have two Enumerables, and you want to see if they have the same elements.
  """

  defmacro __using__(_opts) do
    quote do
      @doc """
      Takes two elements and returns `true` if they are equal, ignoring order for Enumerables.
      Order is also ignored for nested Enumerables.

      ### Examples:

      ```
      iex> Morphix.equaliform?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [["two", :three], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      true

      iex> Morphix.equaliform?([1, "two", :three, %{a: 1, c: "three", e: %{g: 4, b: 2}}], ["two", :three, 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      false

      ```
      """

      @spec equaliform?(any(), any()) :: boolean
      def equaliform?(any1, any2) when is_tuple(any1) and is_tuple(any2) do
        equaliform?(Tuple.to_list(any1), Tuple.to_list(any2))
      end

      def equaliform?(any1, any2) do
        equaliform?(both_enumerables?(any1, any2), any1, any2)
      end

      defp equaliform?(true, enum1, enum2), do: sort_elem(enum1) == sort_elem(enum2)
      defp equaliform?(false, any1, any2), do: any1 == any2

      @doc """
      Takes two elements and returns `true` if they are equal, ignoring order for Enumerables.
      Order is not ignored for nested Enumerables.

      ### Examples:

      ```
      iex> Morphix.equalify?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [["two", :three], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      true

      iex> Morphix.equalify?([1, ["two", :three], %{a: 1, c: "three", e: %{d: 4, b: 2}}], [[:three, "two"], 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      false

      ```
      """

      @spec equalify?(any(), any()) :: boolean
      def equalify?(any1, any2) when is_tuple(any1) and is_tuple(any2) do
        equalify?(Tuple.to_list(any1), Tuple.to_list(any2))
      end

      def equalify?(any1, any2) do
        equalify?(both_enumerables?(any1, any2), any1, any2)
      end

      defp equalify?(true, enum1, enum2), do: Enum.sort(enum1) == Enum.sort(enum2)
      defp equalify?(false, any1, any2), do: any1 == any2

      defp both_enumerables?(any1, any2) do
        case Enumerable.impl_for(any1) && Enumerable.impl_for(any2) do
          nil -> false
          _ -> true
        end
      end

      defp sort_elem(list) when is_list(list) do
        list
        |> Keyword.keyword?()
        |> sort_elem(list)
      end

      defp sort_elem(map) when is_map(map) do
        map
        |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, sort_elem(v)) end)
        |> Enum.sort()
      end

      defp sort_elem(elem), do: elem

      defp sort_elem(true, list) do
        list
        |> Enum.reduce([], fn {k, v}, acc -> acc ++ [sort_elem(v)] end)
        |> Enum.sort()
      end

      defp sort_elem(false, list) do
        list
        |> Enum.reduce([], fn elem, acc -> acc ++ [sort_elem(elem)] end)
        |> Enum.sort()
      end
    end
  end
end
