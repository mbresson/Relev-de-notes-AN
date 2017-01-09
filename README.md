# Relevé de notes AN

Relevé de notes AN (National Assembly's Academic Transcript)
is a short project to put into practice what I'm learning about the [Elixir programming language](http://elixir-lang.org/).
Its purpose is simple:

 * Fetch data from the API provided by [NosDéputés.fr](https://www.nosdeputes.fr) which contains information on the attendance and activity of each delegate in France's National Assembly.
 * Prettify and output this data, optionally sorted.
 * Have fun on my own.

## Dependencies

This project requires:

 * Elixir to be installed
 * [sweet_xml](https://hex.pm/packages/sweet_xml) (used for XML parsing)
 * [httpoison](https://github.com/edgurgel/httpoison) (used for HTTP GET)

## Usage

```sh
mix deps.get
mix escript.build
./relevé_de_notes_an
```
