# NervesMountManager

Monitors and reports changes to the mounted filesystems on a
[Nerves](https://nerves-project.org/) device.

## Installation

The package can be installed by adding `nerves_mount_manager` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nerves_mount_manager, git: "https://github.com/brandonmenc/nerves_mount_manager"}
  ]
end
```

## Example

[NervesDiskMountExample](https://github.com/brandonmenc/nerves_disk_mount_example)
is an example app that uses this module.

## Todo

Lots. Not production ready.

## See also

[NervesDiskManager](https://github.com/brandonmenc/nerves_disk_manager)

## How it works

`NervesMountManager.MountWatcher` polls the `/proc/mounts` file with a C program
and when the file changes, the `SystemRegistry` is updated with the state of the
mounted filesystems.

Each line of `/proc/mounts` is parsed into a keyword list. For example, if the
last line is:

```
/dev/sda1 /mnt vfat rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,flush,errors=remount-ro 0 0
```

it will parse as:

```elixir
iex> SystemRegistry.match(:_) |> get_in([:state, :mounts, :mounts]) |> List.last()
[
  options: %{
    "codepage" => "437",
    "dmask" => "0022",
    "errors" => "remount-ro",
    "flush" => true,
    "fmask" => "0022",
    "iocharset" => "iso8859-1",
    "relatime" => true,
    "rw" => true,
    "shortname" => "mixed"
  },
  device: "/dev/sda1",
  mount_point: "/mnt",
  type: "vfat",
  freq: "0",
  passno: "0"
]
```

Notice how the flag options (like `flush`) are parsed.

Three lists of mounts are maintained:

```elixir
iex> SystemRegistry.match(:_) |> get_in([:state, :mounts]) |> Map.keys()
[:added, :mounts, :removed]
```

`:mounts` is a list of all the currently mounted filesystems, in the above
format. `:added` is a subset of `:mounts` - a list of all the filesystems that
were mounted since the last time the state was updated. `:removed` is a list
of all the filesystems that were unmounted since the last time the state was
updated. The format of the entries in `:added` and `:removed` is the same as
in `:mounts`.

Sometimes you just want to check `:mounts` for a specific disk partition, but
you can also build more complex logic based on the `:added` and `:removed`
lists.
