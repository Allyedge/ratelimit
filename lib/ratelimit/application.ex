defmodule Ratelimit.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Ratelimit.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: Ratelimit.DynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Ratelimit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
