defmodule NewrelicElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :newrelic_elixir,
     version: "0.2.0",
     elixir: "~> 1.1.0",
     compilers: Mix.compilers ++ [:cure, :"cure.deps"],
     deps: deps]
  end

  def application do
    [applications: [:logger, :cure]]
  end

  defp deps do
    [{:cure, "~> 0.4.1"}, {:exprotobuf, ">=1.0.0-rc1"}]
  end

  defp package do
    [maintainers: ["Joey Feldberg"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/joeyfeldberg/newrelic-elixir"}]
  end
end
