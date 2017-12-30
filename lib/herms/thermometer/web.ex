defmodule Herms.Thermometer.Web do

  def init(_, req, state) do
    {:ok, req, state}
  end

  def handle(req, state) do
    headers = [{"content-type", "text/html"}]
    body = to_html()
    {:ok, reply} = :cowboy_req.reply(200, headers, body, req)
    {:ok, reply, state}
  end

  def terminate(_, _, _) do
    :ok
  end

  def to_html() do
    temps = Herms.Thermometer.Worker.read()
    """
      <!doctype html>
      <html> <head>
          <title>Herms Temp Readings</title>
          <meta charset="utf-8">
          <script>
						function connect() {
                // handy globals
                window.mt_bottom = document.getElementById("mt_bottom");
                window.mt_top = document.getElementById("mt_top");
                window.mt_average = document.getElementById("mt_average");
                window.hlt = document.getElementById("hlt");

								wsHost = "ws://" + window.location.host + "/ws";
								websocket = new WebSocket(wsHost);

								websocket.onopen = function(evt) {
                  console.log("onopen");
                  console.log(evt);
								};

								websocket.onclose = function(evt) {
                  console.log("onclose");
                  console.log(evt);
                };

								websocket.onmessage = function(evt) {
                  var data = JSON.parse(evt.data);
                  var el = window[data.sensor];
                  el.innerHTML = data.reading;
                  console.log("onmessage");
                  console.log(evt.data);
                  update_mt_average();
                };

								websocket.onerror = function(evt) {
                  console.log("onerror");
                  console.log(evt);
                };
						};

            function update_mt_average() {
              var t = parseFloat(window["mt_top"].innerHTML);
              var b = parseFloat(window["mt_bottom"].innerHTML);
              window["mt_average"].innerHTML = (t + b) / 2;
            }

            window.onload = connect;
          </script>
        </head>
        <body>
          <table>
            <tr>
              <th>Mash tun - top</th>
              <th>Mash tun - bottom</th>
              <th>Mash tun - average</th>
              <th>Hot liquor tank</th>
            </tr>
            <tr>
              <td><span id="mt_top" class="reading">#{temps.mt_top}</span> °C</td>
              <td><span id="mt_bottom" class="reading">#{temps.mt_bottom}</span> °C</td>
              <td><span id="mt_average" class="reading">#{(temps.mt_top + temps.mt_bottom) / 2}</span> °C</td>
              <td><span id="hlt" class="reading">#{temps.hlt}</span> °C</td>
            </tr>
          </table>
        </body>
      </html>
    """
  end
end
