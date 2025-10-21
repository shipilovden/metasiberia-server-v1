#!/usr/bin/env bash
set -e

# Настраиваем Substrata сервер на порт 7600 (внутренний)
echo "Configuring Substrata server for internal port 7600"
sed -i "s#<port>.*</port>#<port>7600</port>#" "$STATE_DIR/substrata_server_config.xml"
sed -i "s#<port>.*</port>#<port>7600</port>#" "/server/server_data/substrata_server_config.xml"

# Логируем конфигурацию для отладки
echo "Substrata server configuration:"
cat "$STATE_DIR/substrata_server_config.xml"

# Запускаем Substrata сервер в фоне
echo "Starting Substrata server in background on port 7600..."
/server/server &
SUBSTRATA_PID=$!

# Ждем, пока Substrata сервер запустится
echo "Waiting for Substrata server to start..."
sleep 15

# Проверяем, что Substrata сервер запустился
if ! kill -0 $SUBSTRATA_PID 2>/dev/null; then
    echo "ERROR: Substrata server failed to start"
    exit 1
fi

echo "Substrata server started successfully (PID: $SUBSTRATA_PID)"

# Запускаем простой HTTP сервер для Render
echo "Starting simple HTTP server for Render on port $PORT..."
exec python3 /simple_server.py