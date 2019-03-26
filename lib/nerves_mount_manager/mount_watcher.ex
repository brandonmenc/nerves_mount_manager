defmodule NervesMountManager.MountWatcher do
  use GenServer
  require Logger

  alias NervesMountManager.Fstab

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    executable = :code.priv_dir(:nerves_mount_manager) ++ '/mountevent'

    port =
      Port.open({:spawn_executable, executable}, [
        {:arg0, "mountevent"},
        :use_stdio,
        :binary,
        :exit_status
      ])

    {:ok, %{port: port}}
  end

  def handle_info({port, {:data, message}}, _state) do
    SystemRegistry.update([:state, :mounts], Fstab.parse(message))

    {:noreply, %{port: port}}
  end
end
