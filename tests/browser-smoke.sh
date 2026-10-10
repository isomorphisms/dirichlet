#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
chrome="$(command -v google-chrome || command -v chromium)"
"$chrome" --version
python3 -m http.server 8098 --bind 127.0.0.1 >/tmp/dirichlet-http.log 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT
for i in $(seq 1 25); do
  if curl -fsS http://127.0.0.1:8098/web/ >/dev/null; then break; fi
  sleep 1
done
curl -fsS http://127.0.0.1:8098/web/ >/dev/null
for mode in 0 1 2 3; do
  url="http://127.0.0.1:8098/web/?smoke=1&model=$mode"
  "$chrome" --headless=new --no-sandbox --disable-dev-shm-usage --enable-unsafe-swiftshader --use-angle=swiftshader --use-gl=angle --enable-webgl --virtual-time-budget=15000 --window-size=1280,900 --user-data-dir="/tmp/dirichlet-chrome-dom-$mode" --dump-dom "$url" >"/tmp/dirichlet-dom-$mode.html" 2>"/tmp/dirichlet-chrome-$mode.log"
  if ! grep -Eq 'data-smoke-pixel="[0-9]+,[0-9]+,[0-9]+,255"' "/tmp/dirichlet-dom-$mode.html"; then
    echo "No live WebGL2 pixel readback for mode $mode"
    grep -E -A2 'id="status"' "/tmp/dirichlet-dom-$mode.html" || true
    tail -n 35 "/tmp/dirichlet-chrome-$mode.log" || true
    exit 1
  fi
  grep -q 'WebGL2 GLSL linked' "/tmp/dirichlet-dom-$mode.html"
  "$chrome" --headless=new --no-sandbox --disable-dev-shm-usage --enable-unsafe-swiftshader --use-angle=swiftshader --use-gl=angle --enable-webgl --virtual-time-budget=15000 --window-size=1280,900 --user-data-dir="/tmp/dirichlet-chrome-shot-$mode" --screenshot="/tmp/dirichlet-browser-portrait-$mode.png" "$url" >/tmp/dirichlet-shot.log 2>&1
  test -s "/tmp/dirichlet-browser-portrait-$mode.png"
  echo "Mode $mode: $(grep -oE 'data-smoke-pixel="[0-9,]+"' "/tmp/dirichlet-dom-$mode.html")"
done
echo "Four actual WebGL2 Wegert GLSL portraits passed (headless browser, not Android)"

parity_url="http://127.0.0.1:8098/tests/shader-parity.html"
"$chrome" --headless=new --no-sandbox --disable-dev-shm-usage --enable-unsafe-swiftshader --use-angle=swiftshader --use-gl=angle --enable-webgl --virtual-time-budget=20000 --window-size=1000,700 --user-data-dir="/tmp/dirichlet-chrome-parity" --dump-dom "$parity_url" >"/tmp/dirichlet-parity-dom.html" 2>"/tmp/dirichlet-parity-chrome.log"
if ! grep -q 'data-parity-status="pass"' "/tmp/dirichlet-parity-dom.html"; then
  echo "WebGL2 shader numerical agreement failed"
  grep -A8 'id="report"' /tmp/dirichlet-parity-dom.html || true
  tail -n 35 /tmp/dirichlet-parity-chrome.log || true
  exit 1
fi
grep -o 'data-parity-points="[0-9]*"' /tmp/dirichlet-parity-dom.html
grep -o 'data-parity-worst="[^"]*"' /tmp/dirichlet-parity-dom.html
echo "WebGL2 shader and independent CPU evaluator agree on bounded grid"
