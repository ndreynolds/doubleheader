defmodule Doppelkopf.Application do
  @moduledoc """
  The OTP application and supervision tree for the Doppelkopf application.
  """

  use Application

  alias DoppelkopfWeb.Endpoint

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # TODO: Game servers need to be supervised.

    children = [
      # Start the endpoint when the application starts
      Endpoint,
      Doppelkopf.MatchMaker

      # {Registry, keys: :unique, name: Doppelkopf.GameRegistry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Doppelkopf.Supervisor
    )
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
