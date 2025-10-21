#!/usr/bin/env bash
set -e

# Настраиваем Substrata сервер на порт Render
echo "Configuring Substrata server for Render port $PORT"
sed -i "s#<port>.*</port>#<port>${PORT}</port>#" "$STATE_DIR/substrata_server_config.xml"
sed -i "s#<port>.*</port>#<port>${PORT}</port>#" "/server/server_data/substrata_server_config.xml"

# Логируем конфигурацию для отладки
echo "Substrata server configuration:"
cat "$STATE_DIR/substrata_server_config.xml"

# Запускаем Substrata сервер напрямую на порту Render
echo "Starting Substrata server directly on port $PORT..."
exec /server/server