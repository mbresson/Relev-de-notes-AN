defmodule ANDataTest do
  use ExUnit.Case
  doctest ReleveDeNotesAN

  import ReleveDeNotesAN.ANData, only: [extract: 1]

  test "if passed correct data, return name and other informations" do
    data = """
    <deputes>
     <depute>
      <id>350</id>
      <nom>Damien Abad</nom>
      <nom_de_famille>Abad</nom_de_famille>
      <prenom>Damien</prenom>
      <groupe_sigle>LR</groupe_sigle>
      <semaines_presence>30</semaines_presence>
      <commission_presences>29</commission_presences>
      <commission_interventions>34</commission_interventions>
      <hemicycle_interventions>105</hemicycle_interventions>
      <hemicycle_interventions_courtes>101</hemicycle_interventions_courtes>
      <amendements_signes>1961</amendements_signes>
      <amendements_adoptes>90</amendements_adoptes>
      <rapports>2</rapports>
      <propositions_ecrites>0</propositions_ecrites>
      <propositions_signees>117</propositions_signees>
      <questions_ecrites>43</questions_ecrites>
      <questions_orales>5</questions_orales>
     </depute>

     <depute>
      <id>247</id>
      <nom>King Kong</nom>
      <nom_de_famille>Kong</nom_de_famille>
      <prenom>King</prenom>
      <groupe_sigle>PS</groupe_sigle>
      <semaines_presence>2</semaines_presence>
      <commission_presences>1</commission_presences>
      <commission_interventions>0</commission_interventions>
      <hemicycle_interventions>0</hemicycle_interventions>
      <hemicycle_interventions_courtes>0</hemicycle_interventions_courtes>
      <amendements_signes>10</amendements_signes>
      <amendements_adoptes>10</amendements_adoptes>
      <rapports>0</rapports>
      <propositions_ecrites>0</propositions_ecrites>
      <propositions_signees>3</propositions_signees>
      <questions_ecrites>1</questions_ecrites>
      <questions_orales>1</questions_orales>
     </depute>
    </deputes>
    """

    assert extract(data) === [
      %{
	amendements_adoptes: 90,
	amendements_signes: 1961,
	commission_interventions: 34,
	commission_presences: 29,
	hemicycle_interventions: 105,
	hemicycle_interventions_courtes: 101,
	nom: 'Damien Abad',
	propositions_ecrites: 0,
	propositions_signees: 117,
	questions_ecrites: 43,
	questions_orales: 5,
	rapports: 2,
	semaines_presence: 30
      },

      %{
	amendements_adoptes: 10,
	amendements_signes: 10,
	commission_interventions: 0,
	commission_presences: 1,
	hemicycle_interventions: 0,
	hemicycle_interventions_courtes: 0,
	nom: 'King Kong',
	propositions_ecrites: 0,
	propositions_signees: 3,
	questions_ecrites: 1,
	questions_orales: 1,
	rapports: 0,
	semaines_presence: 2
      }
    ]
  end
end
