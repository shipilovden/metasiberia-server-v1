#!/usr/bin/env bash
set -e

# Настраиваем Substrata сервер на порт 7600 (внутренний)
echo "Configuring Substrata server for internal port 7600"
sed -i "s#<port>.*</port>#<port>7600</port>#" "$STATE_DIR/substrata_server_config.xml"
sed -i "s#<port>.*</port>#<port>7600</port>#" "/server/server_data/substrata_server_config.xml"

# Логируем конфигурацию для отладки
echo "Substrata server configuration:"
cat "$STATE_DIR/substrata_server_config.xml"

# Запускаем простой HTTP сервер для Render
echo "Starting simple HTTP server for Render on port $PORT..."
exec python3 /simple_server.py