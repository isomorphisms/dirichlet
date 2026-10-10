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
url="http://127.0.0.1:8098/web/?smoke=1"
"$chrome" --headless=new --no-sandbox --disable-dev-shm-usage --enable-unsafe-swiftshader --use-angle=swiftshader --use-gl=angle --enable-webgl --virtual-time-budget=15000 --window-size=1280,900 --user-data-dir=/tmp/dirichlet-chrome-dom --dump-dom "$url" >/tmp/dirichlet-dom.html 2>/tmp/dirichlet-chrome.log
if ! grep -Eq 'data-smoke-pixel="[0-9]+,[0-9]+,[0-9]+,255"' /tmp/dirichlet-dom.html; then
  echo "No WebGL2 rendered pixel was read from the browser"
  grep -E -A2 'id="status"' /tmp/dirichlet-dom.html || true
  tail -n 35 /tmp/dirichlet-chrome.log || true
  exit 1
fi
grep -q 'WebGL2 GLSL linked' /tmp/dirichlet-dom.html
"$chrome" --headless=new --no-sandbox --disable-dev-shm-usage --enable-unsafe-swiftshader --use-angle=swiftshader --use-gl=angle --enable-webgl --virtual-time-budget=15000 --window-size=1280,900 --user-data-dir=/tmp/dirichlet-chrome-shot --screenshot=/tmp/dirichlet-browser-portrait.png "$url" >/tmp/dirichlet-shot.log 2>&1
test -s /tmp/dirichlet-browser-portrait.png
grep -oE 'data-smoke-pixel="[0-9,]+"' /tmp/dirichlet-dom.html
echo "Headless Chromium actual Wegert GLSL draw succeeded (not physical Android)"
