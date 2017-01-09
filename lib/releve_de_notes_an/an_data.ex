defmodule ReleveDeNotesAN.ANData do

  @moduledoc """
  The ANData module is responsible for:
   * Fetching data from the API.
   * Parsing the data (XML format)
  """

  require Logger

  @api_url Application.get_env(:releve_de_notes_an, :api_url)
  @http_options [follow_redirect: true, max_redirect: 10]

  @doc """
  Fetch data for the specified year and month.

  ## Parameters

   * year: integer
   * month: integer

  ## Return

  {:ok, data} or {:error, reason} on failure.
  """
  def fetch(year, month) do

    month_str = if month < 10, do: "0#{month}", else: "#{month}"

    url = "#{@api_url}#{year}-#{month_str}/xml"
    
    Logger.debug "GET #{url}"
    
    HTTPoison.get(url, [], @http_options)
    |> parse
  end

  @doc """
  Fetch data for the last 12 month.

  ## Return

  {:ok, data} or {:error, reason} on failure.
  """
  def fetch do

    url = "#{@api_url}data/xml"
    
    Logger.debug "GET #{url}"

    HTTPoison.get(url, [], @http_options)
    |> parse
  end

  defp parse({:ok, %{status_code: 200, headers: headers, body: body}}) do

    # We need to check for the case where status_code = 200
    # but the HTTP headers contain Status: 404 Not Found.

    # I have found that sometimes the API is kind of broken:
    # even when it returns a 404 Not Found, it also returns HTTP/1.1 200 OK which is interpreted by HTTPoison as 200 OK, even though in reality it is 404.
    # Even browsers like Firefox and Chrome fall into this trap.
    # (quick test: open http://2007-2012.nosdeputes.fr/synthese/2015-7/xml with a network debugger open)
    # As a result, we cannot rely on HTTPoison's status_code field.

    case {"Status", "404 Not Found"} in headers do
      false ->
	Logger.debug "Received 200"
	
	extract(body)
      true ->
	Logger.debug "Received malformed 404"

	parse({:ok, %{status_code: 404}})
    end
  end

  defp parse({:ok, %{status_code: 404}}) do

    Logger.debug "Received 404"

    IO.puts "There is no data for this date"

    System.halt(0)
  end

  defp parse({:error, reason}) do

    Logger.debug "Failed, with reason ="
    Logger.debug reason

    {:error, reason}
  end

  def extract(data) do

    # Example data:
    # <deputes>
    #  <depute>
    #   <id>350</id>
    #   <nom>Damien Abad</nom>
    #   <nom_de_famille>Abad</nom_de_famille>
    #   <prenom>Damien</prenom>
    #   <groupe_sigle>LR</groupe_sigle>
    #   <semaines_presence>30</semaines_presence>
    #   <commission_presences>29</commission_presences>
    #   <commission_interventions>34</commission_interventions>
    #   <hemicycle_interventions>105</hemicycle_interventions>
    #   <hemicycle_interventions_courtes>101</hemicycle_interventions_courtes>
    #   <amendements_signes>1961</amendements_signes>
    #   <amendements_adoptes>90</amendements_adoptes>
    #   <rapports>2</rapports>
    #   <propositions_ecrites>0</propositions_ecrites>
    #   <propositions_signees>117</propositions_signees>
    #   <questions_ecrites>43</questions_ecrites>
    #   <questions_orales>5</questions_orales>
    #   --- useless data
    #  </depute>
    #  ... other deputes
    # </deputes>
    
    import SweetXml, only: [sigil_x: 2]
    
    data |> SweetXml.xpath(
      ~x"//deputes/depute"l,
      nom: ~x"./nom/text()",
      semaines_presence: ~x"./semaines_presence/text()"I,
      commission_presences: ~x"./commission_presences/text()"I,
      commission_interventions: ~x"./commission_interventions/text()"I,
      hemicycle_interventions: ~x"./hemicycle_interventions/text()"I,
      hemicycle_interventions_courtes: ~x"./hemicycle_interventions_courtes/text()"I,
      amendements_signes: ~x"./amendements_signes/text()"I,
      amendements_adoptes: ~x"./amendements_adoptes/text()"I,
      rapports: ~x"./rapports/text()"I,
      propositions_ecrites: ~x"./propositions_ecrites/text()"I,
      propositions_signees: ~x"./propositions_signees/text()"I,
      questions_ecrites: ~x"./questions_ecrites/text()"I,
      questions_orales: ~x"./questions_orales/text()"I
    )
  end

  defp sort_by_to_atom("nom"), do: :nom
  defp sort_by_to_atom("semaines_presence"), do: :semaines_presence
  defp sort_by_to_atom("commission_presences"), do: :commission_presences
  defp sort_by_to_atom("commission_interventions"), do: :commission_interventions
  defp sort_by_to_atom("hemicycle_interventions"), do: :hemicycle_interventions
  defp sort_by_to_atom("hemicycle_interventions_courtes"), do: :hemicycle_interventions_courtes
  defp sort_by_to_atom("amendements_signes"), do: :amendements_signes
  defp sort_by_to_atom("amendements_adoptes"), do: :amendements_adoptes
  defp sort_by_to_atom("rapports"), do: :rapports
  defp sort_by_to_atom("propositions_ecrites"), do: :propositions_ecrites
  defp sort_by_to_atom("propositions_signees"), do: :propositions_signees
  defp sort_by_to_atom("questions_ecrites"), do: :questions_ecrites
  defp sort_by_to_atom("questions_orales"), do: :questions_orales

  def sort(data, sort_by, _sort_asc = true) do
    
    Logger.debug "Sort by #{sort_by}, ascending order"

    with sort_by = sort_by_to_atom(sort_by) do
      mapper = &(&1[sort_by])    
      Enum.sort_by(data, mapper)
    end
  end

  def sort(data, sort_by, _sort_asc = false) do
    
    Logger.debug "Sort by #{sort_by}, descending order"
    
    with sort_by = sort_by_to_atom(sort_by) do
      mapper = &(&1[sort_by])    
      Enum.sort_by(data, mapper, &(>=/2))
    end
  end

  def display(data) do

    columns = [
      nom: "Nom",
      semaines_presence: "SA",
      commission_presences: "CS",
      commission_interventions: "CI",
      hemicycle_interventions: "HIL",
      hemicycle_interventions_courtes: "HIC",
      amendements_signes: "AS",
      amendements_adoptes: "AA",
      rapports: "RE",
      propositions_ecrites: "PE",
      propositions_signees: "PS",
      questions_ecrites: "QE",
      questions_orales: "QO"
    ]

    columns_width = columns
    |> Enum.map(fn({key, title}) -> {key, column_max_width(data, key, title)} end)

    line_width = Enum.sum(Keyword.values(columns_width)) + length(columns_width)*4

    IO.puts String.duplicate("#", line_width)
    
    header = columns
    |> Enum.map(fn({key, title}) -> "# " <> pad_value(title, columns_width[key]) <> " #" end)

    IO.puts header

    data
    |> Enum.map(fn(row) -> Enum.map(columns_width, fn({key, width}) -> "# " <> pad_value(row[key], width) <> " #" end) end)
    |> Enum.map(&IO.puts(&1))
    
    IO.puts String.duplicate("#", line_width)
  end    

  defp column_max_width(data, column_key, column_name) do

    # gives the maximum width a column must have
    # for its longest value to fit in it when printed to the screen
    # if the column's name is wider, its width is the maximum

    # example use 1:
    # data = [
    #   %{a: "Bonjour", b: "Adieu"}
    #   %{a: "Coucou", b: "Salut"}
    #   %{a: "Hi", b: "Bye"}
    #
    # column_key = :a
    # column_name = "hello"
    #
    # => 7, because 7 is the length of the longest value ("Bonjour")
    # works the same way with integers, floats or any type that can be printed
    #
    # example use 2:
    # data = [
    #   %{a: "Bonjour", b: "Adieu"}
    #   %{a: "Coucou", b: "Salut"}
    #   %{a: "Hi", b: "Bye"}
    #
    # column_key = :a
    # column_name = "Greetings"
    #
    # => 9, because 9 is the length of the column's name ("Greetings")
    #       which is longer than all values

    max_value_width = data
    |> Enum.map(fn(row) -> row[column_key] end)
    |> Enum.map(fn(value) -> String.length("#{value}") end)
    |> Enum.max()

    max(max_value_width, String.length(column_name))
  end

  defp pad_value(value, max_width, pad \\ " ") do

    # add the correct number of `pad` before and after `value`
    # for it to be centered and have the same width as max_width
    #
    # examples use:
    # value = 573, max_width = 5, pad = " " => " 573 "
    # value = "Hi", max_width = 5, pad = "?" => "?Hi??"
    
    value_string = "#{value}"

    total_pad = max_width - String.length(value_string)
    left_pad = div total_pad, 2
    right_pad = total_pad - left_pad

    String.duplicate(pad, left_pad) <>
      value_string <>
      String.duplicate(pad, right_pad)
  end
end
