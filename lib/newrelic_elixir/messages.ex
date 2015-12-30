defmodule ElixirNewrelic.Messages do
  use Protobuf, from: Path.expand("../../c_src/operation_msg.proto", __DIR__)
end
