defmodule Ratelimit do
  @default_limit 3
  @default_window_ms 60_000

  def check_rate(client_id) do
    case Registry.lookup(Ratelimit.Registry, client_id) do
      [{_pid, _}] ->
        Ratelimit.Client.check_rate(client_id)

      [] ->
        start_client_process(client_id)
        Ratelimit.Client.check_rate(client_id)
    end
  end

  defp start_client_process(client_id) do
    {limit, window_ms} = fetch_client_rate_limits(client_id)

    DynamicSupervisor.start_child(
      Ratelimit.DynamicSupervisor,
      {Ratelimit.Client, {client_id, limit, window_ms}}
    )
  end

  defp fetch_client_rate_limits(_client_id) do
    {@default_limit, @default_window_ms}
  end
end
