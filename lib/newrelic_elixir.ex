defmodule ElixirNewrelic do

  @newrelic_location Application.get_env(:elixir_newrelic, :newrelic_location, "/usr/local/bin/newrelic")

  @spec start_link() :: {:ok, pid} | {:error, term}
  def start_link() do
    Cure.Server.start_link(@newrelic_location)
  end

  @spec stop(pid) :: :ok
  def stop(server) do
    Cure.Server.stop(server)
  end
end
