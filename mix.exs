defmodule SdNotifyEx.MixProject do
  use Mix.Project

  @github_url "https://github.com/govm/sd_notify_ex"

  def project do
    [
      app: :sd_notify_ex,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "sd_notify for Elixir",
      source_url: @github_url,
      homepage_url: @github_url,
      package: package(),
      aliases: aliases(),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SdNotifyEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:distillery, "~> 1.4", runtime: false}, # for local test
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:earmark, "~> 1.2", only: :dev, runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      quality: ["compile", "dialyzer", "credo --strict"]
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :transitive,
      flags: [:error_handling, :underspecs, :unmatched_returns]
    ]
  end

  defp package do
    [
      maintainers: ["Go Saito"],
      licenses: ["MIT"],
      links: %{"GitHub repository" => @github_url}
    ]
  end
end
