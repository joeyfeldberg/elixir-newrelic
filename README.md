# ElixirNewrelic

New Relic Elixir Agent. This uses the official New Relic Agent SDK.

## Current Status
The New Relic agent SDK can only be built on linux currently.
This is a pre-release, only a simple transaction and error tracing is currently available.

## Getting started

### Add the Cure dependency to your mix.exs file:
```elixir
def deps do
  [{:elixir_newrelic, "~> 0.2.1"}]
end
```
### Fetch & compile dependencies
```sh
mix deps.get
mix deps.compile
```

### download the application or build from source

In the releases there is a 'newrelic' application or you can compile it from source

#### compiling from source

git clone this repository.
```sh
mix deps.get
mix deps.compile
mix compile
mic compile.cure
```

This will also run the Makefile and create the newrelic application file

### install dependencies

1. Install libcurl
2. Install openssl
3. Install protobuf (used for Elixir to C++ communication)
4. Copy the New Relic shared object to /usr/local/lib (can also be found in the release)

### configure the agent

```elixir
config :elixir_newrelic,
  newrelic_location: "/absolute/path/to/newrelic/application",
  license: "my_newrelic_license_key",
  app_name: "my_appname_in_newrelic"
```

### In Elixir

```elixir
{:ok, server} = ElixirNewrelic.start_link
{:ok, init} = ElixirNewrelic.Transaction.init(newrelic)
{:ok, response} = ElixirNewrelic.Transaction.transaction_begin(server, "name")
exception_type = "Error"
error_message = "Something went wrong"
stack_trace = "..."
stack_frame_delimiter = "\n"
{:ok, response} = ElixirNewrelic.Transaction.transaction_notice_error(server, response.transaction_id, exception_type, error_message, stack_trace, stack_frame_delimiter)
{:ok, response} = ElixirNewrelic.Transaction.transaction_end(server, response.transaction_id)
```
