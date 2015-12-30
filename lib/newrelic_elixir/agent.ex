defmodule NewrelicElixir.Agent do
  def send_msg(server, bytes) do
    server |> Cure.send_data bytes, :once
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
