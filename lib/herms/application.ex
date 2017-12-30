defmodule Herms.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # worker(Herms.Worker, [arg1, arg2, arg3]),
      worker(Herms.Thermometer.Worker, []),
      worker(Task, [fn -> start_cowboy() end], restart: :transient)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Herms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_cowboy() do
    routes = [{:_, [{"/",   Herms.Thermometer.Web, []},
                    {"/ws", Herms.Thermometer.WebSocket, []}]}]
    port = Application.get_env(:herms, :port, 80)
    timeout = Application.get_env(:herms, :timeout, 120_000)
    dispatch = :cowboy_router.compile(routes)
    :cowboy.start_http(__MODULE__,
                       10,
                       [port: port],
                       [env: [dispatch: dispatch], timeout: timeout])
  end
end
