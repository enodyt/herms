Firmware
========

Build and deploy
----------------

.. code-block:: bash

  $ cd firmware
  $ export MIX_TARGET=rpi
  $ mix deps.get
  $ mix firmware
  # first time
  $ mix firmware.burn
  # later on
  $ mix firmware.push 192.168.1.4 --target rpi
  # connect to pi and ping store
  $ iex --name h@192.168.1.7 --remsh firmware@192.168.1.4 --cookie secure
  iex(firmware@192.168.1.4)1> :net_adm.ping(:'store@192.168.1.7')
  :pong

Store
=====

Build and run (in shell dev mode)
---------------------------------

.. code-block:: bash

  $ cd store
  $ rebar3 get-deps
  $ rebar3 compile 
  $ rebar3 shell --name store@192.168.1.7 --setcookie secure
  # ping firmware
  (store@192.168.1.7)1> net_adm:ping('firmware@192.168.1.4').
  pong
