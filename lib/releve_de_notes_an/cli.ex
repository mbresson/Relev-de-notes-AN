defmodule ReleveDeNotesAN.CLI do

  @moduledoc """
  The CLI module is responsible for:
   * Parsing command line arguments
   * Implementing the general program flow

  Valid use cases:
   * ./releve_de_notes_an --help
   * ./releve_de_notes_an -h
   * ./releve_de_notes_an 2012 06
   * ./releve_de_notes_an 2012 6
   * ./releve_de_notes_an
  """

  require Logger
  
  def main(argv) do
    argv
    |> parse_args
    |> process
    |> IO.inspect
  end

  @doc """
  Parse command line arguments and return a description of what must be done.

  ## Return

   * :help if the help must be displayed
   * :last_12_months if the data relative to the last 12 months must be fetched
   * [month: M, year: Y] if the data for the month M of the year Y must be fetched
  """
  def parse_args(argv) do
    Logger.debug "Parse arguments #{argv}"
    
    OptionParser.parse(
      argv,
      [
	strict: [ help: :boolean ],
	aliases: [ h: :help ]
      ]
    )
    |> handle_args
  end

  defp handle_args({[ help: true], _, _ }), do: :help

  defp handle_args({_, [ year, month ], _ }) do
    Logger.debug "Received arguments year(#{year}) and month(#{month}), converting to integers"
    
    [
      year: String.to_integer(year),
      month: String.to_integer(month)
    ]
  end

  defp handle_args({_, [], _}), do: :last_12_months

  defp process(:help) do
    IO.puts """
    Usage:  releve_de_notes_an [ YEAR MONTH ]
    YEAR and MONTH, if provided, must be numbers (e.g. 2016 06).
    """
    System.halt(0)
  end

  defp process(:last_12_months) do
    Logger.debug "Show last 12 months"
  end

  defp process([year: year, month: month]) do
    Logger.debug "Show month #{month} of year #{year}"
  end
end
