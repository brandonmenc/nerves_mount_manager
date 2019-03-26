defmodule NervesMountManager.Fstab do
  @moduledoc """
  Utilities for working with the fstab file format.
  """

  @fields [:device, :mount_point, :type, :options, :freq, :passno]

  def parse(string) do
    string
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  def parse_line(string) do
    string
    |> String.split()
    |> zip_fields()
    |> parse_options()
  end

  def parse_options(list) when is_list(list) do
    Keyword.put(list, :options, parse_options(list[:options]))
  end

  def parse_options(string) when is_binary(string) do
    string
    |> String.split(",")
    |> Enum.reduce(%{}, fn option_string, options ->
      case String.split(option_string, "=") do
        [""] -> options
        [option] -> Map.put(options, option, true)
        [option, value] -> Map.put(options, option, value)
      end
    end)
  end

  defp zip_fields(values) do
    Enum.zip(@fields, values)
  end
end
