# SdNotifyEx

`sd_notify` for Elixir

[![hex.pm version](https://img.shields.io/hexpm/v/sd_notify_ex.svg)](https://hex.pm/packages/sd_notify_ex)
[![hex.pm](https://img.shields.io/hexpm/l/sd_notify_ex.svg)](https://github.com/govm/sd_notify_ex/blob/master/LICENSE)

## Usage

```elixir
SdNotifyEx.send("STATUS=Hello!")
SdNotifyEx.ready()
SdNotifyEx.watchdog()
...
```

To start auto watchdog setter
```elixir
config :sd_notify_ex, auto_watchdog: true
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sd_notify_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sd_notify_ex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sd_notify_ex](https://hexdocs.pm/sd_notify_ex).

