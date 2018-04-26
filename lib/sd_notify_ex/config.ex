defmodule SdNotifyEx.Config do
  @moduledoc """
  To start AutoWatchdog, set config
  ```elixir
  config :sd_notify_ex, auto_watchdog: true
  ```
  """

  @spec sockaddr() :: String.t() | nil
  def sockaddr do
    System.get_env("NOTIFY_SOCKET")
    |> unix_name
  end

  @spec watchdog_msec() :: non_neg_integer() | nil
  def watchdog_msec do
    usec_str = System.get_env("WATCHDOG_USEC")

    if usec_str do
      usec_str
      |> String.to_integer()
      |> div(1000)
    else
      nil
    end
  end

  @spec auto_watchdog() :: boolean() | as_boolean(nil)
  def auto_watchdog do
    config = Application.get_env(:sd_notify_ex, :auto_watchdog, false)
    config && sockaddr() && watchdog_msec() && true
  end

  defp unix_name("@" <> addr), do: "\0" <> addr
  defp unix_name(addr), do: addr
end
