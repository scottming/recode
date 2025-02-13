defmodule Recode.MixProject do
  use Mix.Project

  @version "0.5.1"
  @source_url "https://github.com/hrzndhrn/recode"

  def project do
    [
      app: :recode,
      version: @version,
      elixir: "~> 1.13",
      name: "Recode",
      description: description(),
      docs: docs(),
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      deps: deps(),
      package: package(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mix, :ex_unit, :crypto]
    ]
  end

  defp description do
    "An experimental linter with autocorrection and a refactoring tool."
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      formatters: ["html"],
      groups_for_modules: [
        Tasks: [
          Recode.Task.AliasExpansion,
          Recode.Task.AliasOrder,
          Recode.Task.EnforceLineLength,
          Recode.Task.Format,
          Recode.Task.PipeFunOne,
          Recode.Task.SinglePipe,
          Recode.Task.Specs,
          Recode.Task.TestFileExt,
          Recode.Task.UnusedVariable
        ]
      ]
    ]
  end

  defp dialyzer do
    [
      ignore_warnings: ".dialyzer_ignore.exs",
      plt_file: {:no_warn, "test/support/plts/dialyzer.plt"},
      flags: [:unmatched_returns]
    ]
  end

  def preferred_cli_env do
    [
      carp: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.github": :test
    ]
  end

  defp aliases do
    [
      carp: "test --seed 0 --max-failures 1"
    ]
  end

  defp deps do
    [
      {:bunt, "~> 0.2"},
      {:glob_ex, "~> 0.1"},
      {:rewrite, "~> 0.6"},
      # dev/test
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.25", only: :dev, runtime: false},
      {:excoveralls, "~> 0.15", only: :test},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
