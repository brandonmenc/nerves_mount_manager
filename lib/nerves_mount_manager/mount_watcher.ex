defmodule NervesMountManager.MountWatcher do
  use GenServer
  require Logger

  alias NervesMountManager.Fstab

  defmodule State do
    defstruct [:port, mounts: []]
  end

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

    force_update(port)

    {:ok, %State{port: port}}
  end

  def force_update(port) do
    pid = Port.info(port)[:os_pid]

    System.cmd("kill", ["-USR1", "#{pid}"])
  end

  def handle_info({_port, {:data, message}}, %State{} = state) do
    mounts = Fstab.parse(message)

    SystemRegistry.update([:state, :mounts], %{
      mounts: mounts,
      added: mounts -- state.mounts,
      removed: state.mounts -- mounts
    })

    {:noreply, %{state | mounts: mounts}}
  end
end
