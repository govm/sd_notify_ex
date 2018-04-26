defmodule SdNotifyEx do
  @moduledoc """
  sd_notify for Elixir

  see sd_notify(3), systemd.service(5)
  """

  use GenServer

  alias SdNotifyEx.Config

  defmodule State do
    @moduledoc false
    defstruct socket: nil,
              addr: nil
  end

  def start_link(_ \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    case open_state() do
      {:ok, state} ->
        Process.flag(:trap_exit, true)
        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  def terminate(_reason, state) do
    close_state(state)
    :ok
  end

  @doc """
  send sd_notify by new socket every time
  """
  def send_by_new_socket(data) do
    case open_state() do
      {:ok, state} ->
        ret = send_socket(data, state)
        close_state(state)
        ret

      ret ->
        ret
    end
  end

  def ready do
    send("READY=1")
  end

  def reloading do
    send("RELOADING=1")
  end

  def stopping do
    send("STOPPING=1")
  end

  def status(str) do
    send("STATUS=#{str}")
  end

  def errno(err) do
    send("ERRNO=#{err}")
  end

  def buserror(err) do
    send("BUSERROR=#{err}")
  end

  def mainpid(num) do
    send("MAINPID=#{num}")
  end

  def watchdog do
    send("WATCHDOG=1")
  end

  def watchdog_usec(usec) do
    send("WATCHDOG_USEC=#{usec}")
  end

  def extend_timout_usec(usec) do
    send("EXTEND_TIMEOUT_USEC=#{usec}")
  end

  def fdstore do
    send("FDSTORE=1")
  end

  def fdstoreremove do
    send("FDSTOREREMOVE=1")
  end

  def fdname(name) do
    send("FDNAME=#{name}")
  end

  @doc """
  send sd_notify by reserved socket
  """
  def send(data) do
    GenServer.call(__MODULE__, {:send, data})
  end

  def handle_call({:send, data}, _from, state) do
    {:reply, send_socket(data, state), state}
  end

  defp open_state do
    addr = Config.sockaddr()

    case :gen_udp.open(0, [:binary, :local, {:active, false}]) do
      {:ok, socket} -> {:ok, %State{socket: socket, addr: addr}}
      {:error, _reason} = ret -> ret
    end
  end

  defp close_state(%State{socket: socket}) do
    :gen_udp.close(socket)
  end

  defp send_socket(data, %State{socket: socket, addr: addr}) do
    :gen_udp.send(socket, {:local, addr}, 0, data)
  end
end
