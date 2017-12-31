defmodule Herms.Thermometer.WebSocket do
  @behaviour :cowboy_websocket_handler

  @key {Herms.Thermometer.Worker, :reading} # gproc subscribe key

  require Logger

  def init({:tcp, :http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_type, req, _opts) do
    state = %{}
    :ebus.sub(self(), @key)
    {:ok, req, state}
  end

  def websocket_handle(message, req, state) do
    #Logger.debug(message)
    {:ok, req, state}
  end

  def websocket_info(info, req, state) do
    case info do
      {@key, sensor, temp} ->
        payload = Poison.encode!(%{sensor: sensor, reading: temp})
        {:reply, {:text, payload}, req, state}
      _ ->
        {:reply, {:text, "hallo"}, req, state}
    end
  end

  def websocket_terminate(_reason, _req, _state) do
    :ebus.unsub(self(), @key)
    :ok
  end

end
