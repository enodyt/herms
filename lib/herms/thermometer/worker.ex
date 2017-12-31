defmodule Herms.Thermometer.Worker do
  use GenServer

  require Logger

  @key {__MODULE__, :reading}

  @onewire   'w1'
  @mt_top    '28-0004314eb9ff'
  @mt_bottom '28-0004335680ff'
  @hlt       '28-00043356f2ff'

  defstruct [:hlt, :mt_top, :mt_bottom]

  ## -- api -----------------------------------------------------------------

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :thermometer)
  end

  def read(), do: read(:thermometer)
  def read(server), do: GenServer.call(server, :read)

  def read_mt(), do: read_mt(:thermometer)
  def read_mt(server), do: GenServer.call(server, :read_mt)

  ## -- callbacks -----------------------------------------------------------

  def init([]) do
    {:ok, _, _} = :onewire_therm_manager.subscribe(@onewire, @mt_top)
    {:ok, _, _} = :onewire_therm_manager.subscribe(@onewire, @mt_bottom)
    {:ok, _, _} = :onewire_therm_manager.subscribe(@onewire, @hlt)
    {:ok, %__MODULE__{}}
  end

  def handle_call(:read, _from, state), do: {:reply, state, state}
  def handle_call(:read_mt, _from, state), do:
    {:reply, %{top: state.mt_top, bottom: state.mt_bottom}, state}
  def handle_call(:read_hlt, _from, state), do:
    {:reply, state.hlt, state}

  def handle_info({:therm, {@onewire, @mt_top}, temp, _time}, state), do:
    handle_reading(:mt_top, temp, state)
  def handle_info({:therm, {@onewire, @mt_bottom}, temp, _time}, state), do:
    handle_reading(:mt_bottom, temp, state)
  def handle_info({:therm, {@onewire, @hlt}, temp, _time}, state), do:
    handle_reading(:hlt, temp, state)
  def handle_info(_, state), do: {:noreply, state}

  ## -- helpers -------------------------------------------------------------

  def handle_reading(sensor, temp, state) do
    :ebus.pub(@key, {@key, sensor, temp})
    {:noreply, Map.put(state, sensor, temp)}
  end
end
