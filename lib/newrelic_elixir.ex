defmodule NewrelicElixir do
  require Logger

  @spec start_link() :: {:ok, pid} | {:error, term}
  def start_link() do
    Cure.Server.start_link("./c_src/newrelic")
    Logger.info "Newrelic started"
  end

  @spec stop(pid) :: :ok
  def stop(server) do
    Cure.Server.stop(server)
  end
end
