defmodule CLITest do
  use ExUnit.Case
  doctest ReleveDeNotesAN

  import ReleveDeNotesAN.CLI, only: [parse_args: 1]
  
  test "if passed '--help' or '-h', return :help" do
    assert parse_args(["--help"]) === :help
    assert parse_args(["-h"]) === :help
    assert parse_args(["--help", "trailing argument"]) === :help
    assert parse_args(["-h", "trailing argument", "another useless argument"]) === :help
  end

  test "if passed nothing, return :last_12_months" do
    assert parse_args([]) === :last_12_months
  end

  test "if passed a year Y and a month M, return [year: Y, month: M]" do
    assert parse_args(["2012", "12"]) === [year: 2012, month: 12]
    assert parse_args(["2012", "02"]) === [year: 2012, month: 2]
  end
end
