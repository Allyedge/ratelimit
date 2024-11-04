defmodule Ratelimit.Client do
  use GenServer

  def start_link({client_id, limit, window_ms}) do
    GenServer.start_link(__MODULE__, {limit, window_ms}, name: via_tuple(client_id))
  end

  def init({limit, window_ms}) do
    {:ok, %{limit: limit, window_ms: window_ms, timestamps: []}}
  end

  def handle_call(:check, _from, state) do
    now = System.monotonic_time(:millisecond)
    window_start = now - state.window_ms
    timestamps = Enum.filter(state.timestamps, fn ts -> ts > window_start end)

    if length(timestamps) < state.limit do
      {:reply, :ok, %{state | timestamps: [now | timestamps]}}
    else
      {:reply, {:error, :rate_limit_exceeded}, state}
    end
  end

  def check_rate(client_id) do
    GenServer.call(via_tuple(client_id), :check)
  end

  defp via_tuple(client_id) do
    {:via, Registry, {Ratelimit.Registry, client_id}}
  end
end
