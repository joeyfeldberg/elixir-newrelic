# ElixirNewrelic

New Relic Elixir Agent. This uses the official New Relic Agent SDK.

## Current Status
This project can be built only on linux due to newrelic libraries only support linux.

## Getting started

### Add the Cure dependency to your mix.exs file:
```elixir
def deps do
	[{:elixir_newrelic, "~> 0.2.0"}]
end
```
### Fetch & compile dependencies
```
mix deps.get
mix deps.compile
```
