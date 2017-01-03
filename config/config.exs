# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, compile_time_purge_level: :debug

# format of the API url: url + YEAR-MONTH + /json or /xml
# where YEAR and MONTH are respectively 4 and 2 digits numbers
# e.g. https://www.nosdeputes.fr/synthese/
config :releve_de_notes_an, api_url: "https://www.nosdeputes.fr/synthese/"

