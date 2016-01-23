defmodule ElixirNewrelic.Api.Agent do
  alias ElixirNewrelic.Comm
  alias ElixirNewrelic.Messages

  @type agent_reponse :: {:ok, Messages.Response} | {:error, atom}

  @spec init(server :: pid) :: agent_reponse
  def init(server) do
    license = Application.get_env(:elixir_newrelic, :license)
    app_name = Application.get_env(:elixir_newrelic, :app_name)
    op = Messages.Operation.Init.new(license: license,
                                      app_name: app_name,
                                      language: "Elixir",
                                      language_version: System.version())

    msg = Messages.Operation.new(type: :INIT, init: op)
    Comm.send_msg(server, msg)
  end

  @spec enable_instrumentation(server :: pid, enabled :: boolean) :: agent_reponse
  def enable_instrumentation(server, enabled) do
    op = Messages.Operation.EnableInstrumentation.new(set_enabled: enabled)
    msg = Messages.Operation.new(type: :ENABLE_INSTRUMENTATION,
                                  enable_instrumentation: op)
    Comm.send_msg(server, msg)
  end

  def record_metric(server, name, value) do
    op = Messages.Operation.RecordMetric.new(name: name, value: value)
    msg = Messages.Operation.new(type: :RECORD_METRIC, record_metric: op)
    Comm.send_msg(server, msg)
  end

  def record_cpu_usage(server, cpu_user_time_seconds, cpu_usage_percent) do
    op = Messages.Operation.RecondCPUUsage.new(
              cpu_user_time_seconds: cpu_user_time_seconds,
              cpu_usage_percent: cpu_usage_percent)
    msg = Messages.Operation.new(type: :RECORD_CPU_USAGE, record_cpu_usage: op)
    Comm.send_msg(server, msg)
  end

  def record_memory_usage(server, memory_megabytes) do
    op = Messages.Operation.RecondMemoryUsage.new(memory_megabytes: memory_megabytes)
    msg = Messages.Operation.new(type: :RECORD_MEMORY_USAGE, record_memory_usage: op)
    Comm.send_msg(server, msg)
  end

end
