defmodule ElixirNewrelic.Comm do
  alias ElixirNewrelic.Messages
  @timeout Application.get_env(:elixir_newrelic, :timeout, 5000)
  @type agent_reponse :: {:ok, Messages.Response} | {:error, atom}

  @spec send_msg(server :: pid, msg :: String.t) :: agent_reponse
  def send_msg(server, msg) do
    Cure.send_data(server, Messages.Operation.encode(msg), :once)
     case recv_data do
       {:ok, res} -> {:ok, Messages.Response.decode(res)}
       {:error, reason} -> {:error, reason}
     end
  end

  defp recv_data do
    receive do
      {:cure_data, msg} ->
        {:ok, msg}
      after @timeout ->
        {:error, :timeout}
    end
  end
end
