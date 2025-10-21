#!/usr/bin/env bash
set -e

echo "=== Metasiberia Substrata Server Startup ==="

# Настраиваем порт для Render
echo "Configuring server for Render port: $PORT"
sed -i "s#<port>.*</port>#<port>${PORT}</port>#" "$STATE_DIR/substrata_server_config.xml"
sed -i "s#<port>.*</port>#<port>${PORT}</port>#" "/server/server_data/substrata_server_config.xml"

# Логируем конфигурацию
echo "Server configuration:"
cat "$STATE_DIR/substrata_server_config.xml"

# Проверяем сертификаты
echo "Checking certificates..."
if [ -f "$STATE_DIR/MyCertificate.crt" ] && [ -f "$STATE_DIR/MyKey.key" ]; then
    echo "✅ TLS certificates found"
    ls -la "$STATE_DIR/MyCertificate.crt" "$STATE_DIR/MyKey.key"
else
    echo "❌ TLS certificates missing!"
    exit 1
fi

# Проверяем webclient
echo "Checking webclient..."
if [ -d "$STATE_DIR/webclient" ]; then
    echo "✅ Webclient directory found"
    ls -la "$STATE_DIR/webclient" | head -5
else
    echo "❌ Webclient directory missing!"
    exit 1
fi

# Запускаем Substrata сервер
echo "Starting Substrata server on port $PORT..."
echo "Server will be available at: https://metasiberia-server-v1.onrender.com"
echo "Web interface: https://metasiberia-server-v1.onrender.com"
echo "Substrata client: sub://metasiberia-server-v1.onrender.com"

exec /server/server