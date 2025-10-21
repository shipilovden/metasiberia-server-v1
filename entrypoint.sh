#!/usr/bin/env bash
set -e

# Если Render задаёт порт, подставим его в конфиг
if [ -n "$PORT" ]; then
  echo "Setting port to $PORT for Render"
  sed -i "s#<port>.*</port>#<port>${PORT}</port>#" "$STATE_DIR/substrata_server_config.xml"
  sed -i "s#<port>.*</port>#<port>${PORT}</port>#" "/server/server_data/substrata_server_config.xml"
else
  echo "No PORT environment variable set, using default 10000"
fi

# Логируем конфигурацию для отладки
echo "Server configuration:"
cat "$STATE_DIR/substrata_server_config.xml"

# Запускаем Substrata server (с TLS как требует официальная инструкция)
echo "Starting Substrata server with TLS..."
exec /server/server