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

    @type t :: %__MODULE__{
            socket: port() | nil,
            addr: String.t() | nil
          }
  end

  @typep send_return_t :: :ok | {:error, term()}

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_ \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(any()) :: {:ok, State.t()} | {:stop, term()}
  def init(_) do
    case open_state() do
      {:ok, state} ->
        Process.flag(:trap_exit, true)
        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @spec terminate(term(), State.t()) :: :ok
  def terminate(_reason, state) do
    close_state(state)
    :ok
  end

  @doc """
  send sd_notify by new socket every time
  """
  @spec send_by_new_socket(iodata()) :: :ok | {:error, term()}
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

  @spec ready() :: send_return_t()
  def ready do
    send("READY=1")
  end

  @spec reloading() :: send_return_t()
  def reloading do
    send("RELOADING=1")
  end

  @spec stopping() :: send_return_t()
  def stopping do
    send("STOPPING=1")
  end

  @spec status(String.Chars.t()) :: send_return_t()
  def status(str) do
    send("STATUS=#{str}")
  end

  @spec errno(String.Chars.t()) :: send_return_t()
  def errno(err) do
    send("ERRNO=#{err}")
  end

  @spec buserror(String.Chars.t()) :: send_return_t()
  def buserror(err) do
    send("BUSERROR=#{err}")
  end

  @spec mainpid(String.Chars.t()) :: send_return_t()
  def mainpid(num) do
    send("MAINPID=#{num}")
  end

  @spec watchdog() :: send_return_t()
  def watchdog do
    send("WATCHDOG=1")
  end

  @spec watchdog_usec(String.Chars.t()) :: send_return_t()
  def watchdog_usec(usec) do
    send("WATCHDOG_USEC=#{usec}")
  end

  @spec extend_timeout_usec(String.Chars.t()) :: send_return_t()
  def extend_timeout_usec(usec) do
    send("EXTEND_TIMEOUT_USEC=#{usec}")
  end

  @spec fdstore() :: send_return_t()
  def fdstore do
    send("FDSTORE=1")
  end

  @spec fdstoreremove() :: send_return_t()
  def fdstoreremove do
    send("FDSTOREREMOVE=1")
  end

  @spec fdname(String.Chars.t()) :: send_return_t()
  def fdname(name) do
    send("FDNAME=#{name}")
  end

  @doc """
  send sd_notify by reserved socket
  """
  @spec send(iodata()) :: send_return_t()
  def send(data) do
    GenServer.call(__MODULE__, {:send, data})
  end

  def handle_call({:send, data}, _from, state) do
    {:reply, send_socket(data, state), state}
  end

  @spec open_state() :: {:ok, State.t()} | {:error, term}
  defp open_state do
    addr = Config.sockaddr()

    case :gen_udp.open(0, [:binary, :local, {:active, false}]) do
      {:ok, socket} -> {:ok, %State{socket: socket, addr: addr}}
      {:error, _reason} = ret -> ret
    end
  end

  @spec close_state(State.t()) :: :ok
  defp close_state(%State{socket: socket}) do
    :gen_udp.close(socket)
  end

  @spec send_socket(iodata(), State.t()) :: send_return_t()
  defp send_socket(data, %State{socket: socket, addr: addr}) do
    :gen_udp.send(socket, {:local, addr}, 0, data)
  end
end
