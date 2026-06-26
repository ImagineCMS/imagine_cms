defmodule Imagine.MixProject do
  use Mix.Project

  def project do
    [
      app: :imagine_cms,
      version: "6.3.7",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Imagine.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    An easy-to-use, self-contained CMS
    """
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "package.json", "LICENSE", "*.md"],
      maintainers: ["Aaron Namba"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/ImagineCMS/imagine_cms"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.8.8"},
      {:phoenix_ecto, "~> 4.7"},
      {:ecto_sql, "~> 3.14"},
      {:myxql, "~> 0.9"},
      {:phoenix_live_view, "~> 1.2"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_view, "~> 2.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.0"},
      {:argon2_elixir, "~> 3.0"},
      {:nebulex, "~> 1.2"},
      {:timex, "~> 3.6"},
      {:floki, ">= 0.0.0"},
      {:nodejs, "~> 2.0"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:dart_sass, "~> 0.7", runtime: Mix.env() == :dev},
      {:mix_test_watch, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      "assets.setup": [
        "deps.get",
        "esbuild.install --if-missing",
        "sass.install --if-missing",
        "cmd --cd assets npm ci"
      ],
      "assets.build": [
        "assets.copy",
        "esbuild frontend",
        "esbuild manage",
        "sass frontend --no-source-map",
        "sass manage --no-source-map"
      ],
      "assets.deploy": [
        "assets.copy",
        "esbuild frontend --minify",
        "esbuild manage --minify",
        "sass frontend --style=compressed --no-source-map",
        "sass manage --style=compressed --no-source-map"
      ]
    ]
  end
end
