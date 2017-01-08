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

  test "if passed nothing, return default sort options" do
    assert parse_args([]) === %{sort_by: "nom", sort_asc: false}
  end

  test "if passed sort parameters, return the corresponding arguments" do

    with parameters = ["--sort-by", "rapports"] do
      assert parse_args(parameters) === %{sort_by: "rapports", sort_asc: false}
    end

    with parameters = ["--sort-by", "rapports", "--sort-asc"] do
      assert parse_args(parameters) === %{sort_by: "rapports", sort_asc: true}
    end
    
    with parameters = ["--sort-asc", "--sort-by", "rapports"] do
      assert parse_args(parameters) === %{sort_by: "rapports", sort_asc: true}
    end
    
    with parameters = ["--sort-asc"] do
      assert parse_args(parameters) === %{sort_by: "nom", sort_asc: true}
    end
  end

  test "if passed a year Y and a month M, return the corresponding arguments" do

    with parameters = ["2012", "12"] do
      assert parse_args(parameters) === %{year: 2012, month: 12, sort_by: "nom", sort_asc: false}
    end

    with parameters = ["2012", "12", "--sort-by", "rapports"] do
      assert parse_args(parameters) === %{year: 2012, month: 12, sort_by: "rapports", sort_asc: false}
    end
    
    with parameters = ["2012", "12", "--sort-asc"] do
      assert parse_args(parameters) === %{year: 2012, month: 12, sort_by: "nom", sort_asc: true}
    end
  end
end
