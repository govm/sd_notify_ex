defmodule SdNotifyEx.AutoWatchdog do
  @moduledoc """
  Automatic watchdog setter
  """

  use GenServer

  alias SdNotifyEx.Config

  @set_per_interval 3

  def start_link(_ \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    watchdog_msec = Config.watchdog_msec()

    if watchdog_msec do
      timer = div(watchdog_msec, @set_per_interval)
      sched(timer)
      {:ok, timer}
    else
      {:stop, "Failed to get WATCHDOG_USEC"}
    end
  end

  def handle_info(:set, timer) do
    SdNotifyEx.watchdog()
    sched(timer)
    {:noreply, timer}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp sched(time) do
    Process.send_after(self(), :set, time)
  end
end
