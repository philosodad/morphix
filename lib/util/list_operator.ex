defmodule Util.ListOperator do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      @doc """
      Takes two ordered or unordered lists and returns `true` if they are equal.

      ### Examples:

      ```
      iex> Morphix.equaliform?([1, "two", :three, %{a: 1, c: "three", e: %{d: 4, b: 2}}], ["two", :three, 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      true

      iex> Morphix.equaliform?([1, "two", :three, %{a: 1, c: "three", e: %{g: 4, b: 2}}], ["two", :three, 1, %{c: "three", a: 1, e: %{b: 2, d: 4}}])
      false

      iex> Morphix.equaliform?(%{a: 1, b: 2, c: 3}, %{b: 2, c: 3, a: 1})
      ** (ArgumentError) expecting a list for each parameter, got: %{a: 1, b: 2, c: 3}, %{a: 1, b: 2, c: 3}

      ```
      """

      @spec equaliform?(list(), list()) :: boolean | %ArgumentError{}
      def equaliform?(list1, list2) when is_list(list1) and is_list(list2) do
        Enum.sort(list1) == Enum.sort(list2)
      end

      def equaliform?(not_list1, not_list2) do
        raise(
          ArgumentError,
          message: "expecting a list for each parameter, got: #{inspect not_list1}, #{inspect not_list2}"
        )
      end
    end
  end
end
