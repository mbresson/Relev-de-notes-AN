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
  
  defp process(:last_12_months) do
    Logger.debug "Show last 12 months"

    ReleveDeNotesAN.ANData.fetch()
  end

  defp process([year: year, month: month]) do
    Logger.debug "Show month #{month} of year #{year}"

    ReleveDeNotesAN.ANData.fetch(year, month)
  end

  defp process(:help) do
    IO.puts """
    Usage:  releve_de_notes_an [ YEAR MONTH ]
    YEAR and MONTH, if provided, must be numbers (e.g. 2016 06).

    Sens de chaque colonne / meaning of the columns:
    (warning: English explanations may be incomplete or incorrect, check the French version for the best accuracy)

     * Semaines d'activité :
         Nombre de semaines où le député a été relevé présent en commission ou a pris la parole (même brièvement) en hémicycle.
         Number of weeks during which the député has attended a parliamentary committee session or has spoken (even shortly) in a plenary session.

     * Commission séances =
         Nombre de séances de commission où le député a été relevé présent.
         Number of parliamentary committee sessions attended by the député.

     * Commission interventions =
         Nombre d'interventions prononcées par le député en commissions.
         Number of times the député has intervened during parliamentary committee sessions.

     * Hémicycle interventions longues =
         Nombre d'interventions de plus de 20 mots prononcées par le député en hémicycle.
         Number of times the député has intervened during plenary sessions (spoke more than 20 words).

     * Hémicycle interventions courtes =
         Nombre d'interventions de 20 mots et moins prononcées par le député en hémicycle.
         Number of times the député has intervened during plenary sessions (spoke 20 words or less).

     * Amendements signés =
         Nombre d'amendements signés ou co-signés par le député.
         Number of amendments signed or co-signed by the député.

     * Amendements adoptés =
         Nombre d'amendements adoptés qui ont été signés ou cosignés par le député.
         Number of amendments passed that have been signed or co-signed by the député.

     * Rapports écrits =
         Nombre de rapports ou avis dont le député est l'auteur.
         Number of notices or reports made by the député.

     * Propositions écrites =
         Nombre de propositions de loi ou de résolution dont le député est l'auteur.
         Number of bills or resolutions originating from the député.

     * Propositions signées =
         Nombre de propositions de loi ou de résolution dont le député est cosignataire.
         Number of bills or resolutions co-signed by the député.

     * Questions écrites =
         Nombre de questions au gouvernement écrites soumises par le député.
         Number of writen questions to the government submitted by the député.

     * Questions orales =
         Nombre de questions au gouvernement orales posées par le député.
         Number of oral questions addressed to the government by the député.

    Toutes les données viennent de https://www.nosdeputes.fr et sont obtenues via son API publique.
    All the data is originating from https://www.nosdeputes.fr and obtained via its public API.

    Plus d'information sur le sens des données sur https://www.nosdeputes.fr/faq.
    More information on the meaning of this data can be found on https://www.nosdeputes.fr/faq.
    """
    System.halt(0)
  end
end
