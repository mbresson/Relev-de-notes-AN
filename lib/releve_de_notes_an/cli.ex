defmodule ReleveDeNotesAN.CLI do

  @moduledoc """
  The CLI module is responsible for:
   * Parsing command line arguments
   * Implementing the general program flow

  Example of use cases:
   * ./releve_de_notes_an --help
   * ./releve_de_notes_an -h
   * ./releve_de_notes_an 2012 06
   * ./releve_de_notes_an 2012 6
   * ./releve_de_notes_an
   * ./releve_de_notes_an --sort-by semaines_presence --sort-order asc
  """
  
  alias ReleveDeNotesAN.ANData
  require Logger
  
  @default_options %{sort_by: "nom", sort_asc: false}
  
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  Parse command line arguments and return a description of what must be done.

  ## Return

   * If the help must be displayed:
     :help

   * If data relative to the last 12 months must be fetched:
     %{sort_by: "column name", sort_asc: boolean}

   * If data for the month M of the year Y must be fetched: (where M and Y are numbers)
     %{sort_by: "column name", sort_asc: boolean, month: M, year: Y}
  """
  def parse_args(argv) do
    Logger.debug "Parse arguments #{argv}"
    
    parsed = OptionParser.parse(
      argv,
      [
	strict: [help: :boolean, sort_by: :string, sort_asc: :boolean],
	aliases: [h: :help]
      ])

    handle_args(parsed)
  end

  defp handle_args({[help: true], _, _}), do: :help

  defp handle_args({options, arguments, _}) do
    
    Logger.debug "Received options = #{inspect options}"

    # maps are more convenient later in function parameter matching
    final_options = Map.merge(@default_options,
      Enum.into(options, %{}))
    
    Logger.debug "Final options = #{inspect final_options}"

    final_args = convert_args(arguments)

    Map.merge(final_args, final_options)
  end

  defp convert_args([year, month]) do
    
    Logger.debug "Received arguments year(#{year}) and month(#{month}), converting to integers"

    %{
      year: String.to_integer(year),
      month: String.to_integer(month)
    }
  end

  defp convert_args([]), do: %{}

  defp process(%{year: year, month: month, sort_by: sort_by, sort_asc: sort_asc}) do
    Logger.debug "Show month #{month} of year #{year}"

    ANData.fetch(year, month)
    |> ANData.sort(sort_by, sort_asc)
    |> IO.inspect
  end

  defp process(%{sort_by: sort_by, sort_asc: sort_asc}) do
    
    # If no year and month is provided, fetch data for the last 12 months.
  
    Logger.debug "Show last 12 months"

    ANData.fetch()
    |> ANData.sort(sort_by, sort_asc)
    |> IO.inspect
  end

  defp process(:help) do
    IO.puts """
    Usage:  releve_de_notes_an [YEAR MONTH] [--sort-by "column name"] [--sort-asc]
    
     * YEAR and MONTH, if provided, must be numbers (e.g. 2016 06).
     * --sort-by must be followed by the name of one of the columns of data available, e.g. "semaines_presence" for Semaines d'activité (see below).

    Sens de chaque colonne / meaning of the columns:
    (warning: English explanations may be incomplete or incorrect, check the French version for the best accuracy)

     * Nom (nom) = nom complet du député / député's full name

     * Semaines d'activité (semaines_presence) =
         Nombre de semaines où le député a été relevé présent en commission ou a pris la parole (même brièvement) en hémicycle.
         Number of weeks during which the député has attended a parliamentary committee session or has spoken (even shortly) in a plenary session.

     * Commission séances (commission_presences) =
         Nombre de séances de commission où le député a été relevé présent.
         Number of parliamentary committee sessions attended by the député.

     * Commission interventions (commission_interventions) =
         Nombre d'interventions prononcées par le député en commissions.
         Number of times the député has intervened during parliamentary committee sessions.

     * Hémicycle interventions longues (hemicycle_interventions) =
         Nombre d'interventions de plus de 20 mots prononcées par le député en hémicycle.
         Number of times the député has intervened during plenary sessions (spoke more than 20 words).

     * Hémicycle interventions courtes (hemicycle_interventions_courtes) =
         Nombre d'interventions de 20 mots et moins prononcées par le député en hémicycle.
         Number of times the député has intervened during plenary sessions (spoke 20 words or less).

     * Amendements signés (amendements_signes) =
         Nombre d'amendements signés ou co-signés par le député.
         Number of amendments signed or co-signed by the député.

     * Amendements adoptés (amendements_adoptes) =
         Nombre d'amendements adoptés qui ont été signés ou cosignés par le député.
         Number of amendments passed that have been signed or co-signed by the député.

     * Rapports écrits (rapports) =
         Nombre de rapports ou avis dont le député est l'auteur.
         Number of notices or reports made by the député.

     * Propositions écrites (propositions_ecrites) =
         Nombre de propositions de loi ou de résolution dont le député est l'auteur.
         Number of bills or resolutions originating from the député.

     * Propositions signées (propositions_signees) =
         Nombre de propositions de loi ou de résolution dont le député est cosignataire.
         Number of bills or resolutions co-signed by the député.

     * Questions écrites (questions_ecrites) =
         Nombre de questions au gouvernement écrites soumises par le député.
         Number of writen questions to the government submitted by the député.

     * Questions orales (questions_orales) =
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
