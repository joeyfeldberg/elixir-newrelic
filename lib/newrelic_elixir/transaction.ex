defmodule ElixirNewrelic.Transaction do
  alias ElixirNewrelic.Agent
  alias ElixirNewrelic.Messages

  @timeout Application.get_env(:elixir_newrelic, :timeout, 500)

  def init(server) do
    license = Application.get_env(:elixir_newrelic, :license)
    app_name = Application.get_env(:elixir_newrelic, :app_name)
    sub = Messages.Operation.Init.new(license: license,
                                      app_name: app_name,
                                      language: "Elixir",
                                      language_version: System.version())

    msg = Messages.Operation.new(type: :INIT, init: sub)
    send_msg(server, msg)
  end

  def transaction_begin(server, name) do
    sub = Messages.Operation.TransactionBegin.new(name: name)
    msg = Messages.Operation.new(type: :TRANSACTION_BEGIN, transaction_begin: sub)
    send_msg(server, msg)
  end

  def transaction_end(server, transaction_id) do
    sub = Messages.Operation.TransactionEnd.new(transaction_id: transaction_id)
    msg = Messages.Operation.new(type: :TRANSACTION_END, transaction_end: sub)
    send_msg(server, msg)
  end

  def transaction_notice_error(server, transaction_id, exception_type,
                          error_message, stack_trace, stack_frame_delimiter) do
    sub = Messages.Operation.NoticeError.new(
              transaction_id: transaction_id,
              exception_type: exception_type,
              error_message: error_message,
              stack_trace: stack_trace,
              stack_frame_delimiter: stack_frame_delimiter)

    msg = Messages.Operation.new(type: :TRANSACTION_NOTICE_ERROR, notice_error: sub)
    send_msg(server, msg)
  end

  def send_msg(server, msg) do
     Agent.send_msg(server, Messages.Operation.encode(msg))
     {:ok, res} = Agent.recv(500)
     {:ok, Messages.Response.decode(res)}
  end
end
