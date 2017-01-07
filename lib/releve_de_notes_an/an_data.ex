defmodule ReleveDeNotesAN.ANData do

  @moduledoc """
  The ANData module is responsible for:
   * Fetching data from the API.
   * Parsing the data (XML format)
  """

  require Logger

  @api_url Application.get_env(:releve_de_notes_an, :api_url)
  @http_options [ follow_redirect: true, max_redirect: 10 ]

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
	Logger.debug "Received 200 with data ="
	Logger.debug body
	
	extract(body)
      true ->
	Logger.debug "Received malformed 404"

	parse({:ok, %{status_code: 404}})
    end
  end

  defp parse({:ok, %{status_code: 404}}) do

    Logger.debug "Received 404"
    
    {:error, "No data found"}
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
    
    import SweetXml, only: [ sigil_x: 2 ]
    
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
  
end
