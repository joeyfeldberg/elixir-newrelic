defmodule ElixirNewrelic.Agent do
  def send_msg(server, bytes) do
    Cure.send_data(server, bytes, :once)
  end

  def recv(timeout) do
    receive do
      {:cure_data, msg} ->
        {:ok, msg}
      _ ->
        {:error, :no_response}
      after timeout ->
        {:error, :timeout}
    end
  end
end
