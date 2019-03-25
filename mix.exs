defmodule NervesMountManager.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :nerves_mount_manager,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/brandonmenc/nerves_mount_manager",
      homepage_url: "https://github.com/brandonmenc/nerves_mount_manager",
      name: "Nerves Mount Manager",
      description: """
      Monitors filesystem mounts.
      """
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
    ]
  end

  defp package do
    [
      maintainers: ["Brandon Menc"],
      licenses: ["Apache-2.0"],
      links: %{github: "https://github.com/brandonmenc/nerves_mount_manager"}
    ]
  end
end
