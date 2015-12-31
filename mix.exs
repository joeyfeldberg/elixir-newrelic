defmodule ElixirNewrelic.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_newrelic,
     version: "0.2.1",
     elixir: "~> 1.1.0",
     description: "New Relic Elixir Agent",
     deps: deps,
     package: package]
  end

  def application do
    [applications: [:logger, :cure]]
  end

  defp deps do
    [{:cure, "~> 0.4.1"}, {:exprotobuf, ">=1.0.0-rc1"}]
  end

  defp package do
    [files: ~w(lib c_src mix.exs README* readme* LICENSE* license*),
     maintainers: ["Joey Feldberg"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/joeyfeldberg/elixir-newrelic"}]
  end
end
