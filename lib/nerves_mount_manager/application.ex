defmodule NervesMountManager.Application do
  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: NervesMountManager.Supervisor]

    Supervisor.start_link([NervesMountManager.MountWatcher], opts)
  end
end
