defmodule ElixirNewrelic.Api.Transaction do
  alias ElixirNewrelic.Comm
  alias ElixirNewrelic.Messages

  @type agent_reponse :: {:ok, Messages.Response} | {:error, atom}

  def transaction_begin(server, name, set_type_web \\ nil, category \\ nil,
                          request_url \\ nil, max_trace_segments \\ nil) do
    sub = Messages.Operation.TransactionBegin.new(
              name: name,
              set_type_web: set_type_web,
              category: category,
              request_url: request_url,
              max_trace_segments: max_trace_segments)
    msg = Messages.Operation.new(type: :TRANSACTION_BEGIN, transaction_begin: sub)
    Comm.send_msg(server, msg)
  end

  def transaction_end(server, transaction_id) do
    sub = Messages.Operation.TransactionEnd.new(transaction_id: transaction_id)
    msg = Messages.Operation.new(type: :TRANSACTION_END, transaction_end: sub)
    Comm.send_msg(server, msg)
  end

  def transaction_notice_error(server, transaction_id, exception_type,
                          error_message, stack_trace, stack_frame_delimiter) do
    sub = Messages.Operation.TransactionNoticeError.new(
              transaction_id: transaction_id,
              exception_type: exception_type,
              error_message: error_message,
              stack_trace: stack_trace,
              stack_frame_delimiter: stack_frame_delimiter)

    msg = Messages.Operation.new(
              type: :TRANSACTION_NOTICE_ERROR,
              transaction_notice_error: sub)
    Comm.send_msg(server, msg)
  end

  def transaction_add_attribute(server, transaction_id, name, value) do
    sub = Messages.Operation.TransactionAddAttribute.new(
              transaction_id: transaction_id,
              name: name,
              value: value,)
    msg = Messages.Operation.new(type: :TRANSACTION_ADD_ATTRIBUTE,
                                  transaction_add_attribute: sub)
    Comm.send_msg(server, msg)
  end

end
