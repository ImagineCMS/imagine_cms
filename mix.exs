defmodule Imagine.MixProject do
  use Mix.Project

  def project do
    [
      app: :imagine_cms,
      version: "6.3.7",
      elixir: "~> 1.10",
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
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
      {:phoenix, "~> 1.5.3"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.0"},
      {:myxql, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.14"},
      {:phoenix_html, "~> 2.14"},
      {:gettext, "~> 0.17"},
      {:jason, "~> 1.0"},
      {:argon2_elixir, "~> 2.0"},
      {:nebulex, "~> 1.2"},
      {:timex, "~> 3.6"},
      {:floki, ">= 0.0.0"},
      {:nodejs, "~> 2.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
