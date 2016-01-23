defmodule ElixirNewrelic.Api.Segment do
  alias ElixirNewrelic.Comm
  alias ElixirNewrelic.Messages

  @type agent_reponse :: {:ok, Messages.Response} | {:error, atom}

  def segment_generic_begin(server, transaction_id, parent_segment_id, name) do
    sub = Messages.Operation.SegmentGenericBegin.new(
              transaction_id: transaction_id,
              parent_segment_id: parent_segment_id,
              name: name)
    msg = Messages.Operation.new(type: :SEGMENT_GENERIC_BEGIN,
                                  segment_generic_begin: sub)
    Comm.send_msg(server, msg)
  end

  def segment_datastore_begin(server, transaction_id, parent_segment_id,
                              table, operation, sql) do
    sub = Messages.Operation.SegmentDatastoreBegin.new(
              transaction_id: transaction_id,
              parent_segment_id: parent_segment_id,
              table: table,
              operation: operation,
              sql: sql)
    msg = Messages.Operation.new(type: :SEGMENT_DATASTORE_BEGIN,
                                  segment_datastore_begin: sub)
    Comm.send_msg(server, msg)
  end

  def segment_external_begin(server, transaction_id, parent_segment_id, host, name) do
    sub = Messages.Operation.SegmentExternalBegin.new(
              transaction_id: transaction_id,
              parent_segment_id: parent_segment_id,
              host: host,
              name: name)
    msg = Messages.Operation.new(type: :SEGMENT_EXTERNAL_BEGIN,
                                  segment_external_begin: sub)
    Comm.send_msg(server, msg)
  end

  def segment_end(server, transaction_id, segment_id) do
    sub = Messages.Operation.SegmentEnd.new(
              transaction_id: transaction_id,
              segment_id: segment_id)
    msg = Messages.Operation.new(type: :SEGMENT_END, segment_end: sub)
    Comm.send_msg(server, msg)
  end
end
