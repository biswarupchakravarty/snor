defmodule Snor.MixProject do
  use Mix.Project

  def project do
    [
      app: :snor,
      version: "0.5.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  defp description do
    """
    A simple and fast implementation of basic features of Mustache templating
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Biswarup Chakravarty"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/biswarupchakravarty/snor",
        "Docs" => "http://hexdocs.pm/snor/"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev},
      {:earmark, "~> 1.4", only: :dev},
      {:yaml_elixir, "~> 2.4", only: [:dev, :test]},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
