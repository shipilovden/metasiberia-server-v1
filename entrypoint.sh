#!/usr/bin/env bash
set -e

# Если Render задаёт порт, подставим его в конфиг
if [ -n "$PORT" ]; then
  sed -i "s#<port>.*</port>#<port>${PORT}</port>#" /server/server_data/substrata_server_config.xml
fi

# Запускаем Substrata server
exec /server/server