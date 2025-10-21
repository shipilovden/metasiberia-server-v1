#!/usr/bin/env bash
set -e

# Если Render задаёт порт, подставим его в конфиг
if [ -n "$PORT" ]; then
  sed -i "s#<port>.*</port>#<port>${PORT}</port>#" "$STATE_DIR/substrata_server_config.xml"
fi

# Удаляем TLS файлы, если они есть (для HTTP режима)
rm -f "$STATE_DIR/MyCertificate.crt" "$STATE_DIR/MyKey.key"

# Запускаем Substrata server
exec /server/server