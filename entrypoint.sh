#!/usr/bin/env bash
set -e

# Если Render задаёт порт, подставим его в конфиг
if [ -n "$PORT" ]; then
  echo "Setting port to 7600 for Substrata server"
  sed -i "s#<port>.*</port>#<port>7600</port>#" "$STATE_DIR/substrata_server_config.xml"
  sed -i "s#<port>.*</port>#<port>7600</port>#" "/server/server_data/substrata_server_config.xml"
else
  echo "No PORT environment variable set, using default 7600 for Substrata"
fi

# Удаляем TLS файлы, если они есть (для HTTP режима)
rm -f "$STATE_DIR/MyCertificate.crt" "$STATE_DIR/MyKey.key"

# Логируем конфигурацию для отладки
echo "Server configuration:"
cat "$STATE_DIR/substrata_server_config.xml"

# Запускаем Substrata server в фоне
echo "Starting Substrata server on port 7600..."
/server/server &
SUBSTRATA_PID=$!

# Ждем, пока Substrata сервер запустится
echo "Waiting for Substrata server to start..."
sleep 10

# Запускаем HTTP прокси на порту Render
echo "Starting HTTP proxy on port $PORT..."
exec python3 /http_proxy.py