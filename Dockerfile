FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget unzip ca-certificates openssl tar \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /server

# Скачать и распаковать Linux-сервер Substrata
RUN wget -O SubstrataServer_v1.5.7.tar.gz https://downloads.indigorenderer.com/dist/cyberspace/SubstrataServer_v1.5.7.tar.gz \
 && tar -xzf SubstrataServer_v1.5.7.tar.gz \
 && rm SubstrataServer_v1.5.7.tar.gz

# Подготовить структуру данных
RUN mkdir -p /server/server_data/dist_resources /server/server_data/webclient

# Скачать дистрибутивные файлы и веб-клиент
RUN wget -O server_dist_files.zip https://downloads.indigorenderer.com/dist/cyberspace/server_dist_files.zip \
 && unzip -o server_dist_files.zip -d /server/server_data \
 && rm server_dist_files.zip \
 && wget -O substrata_webclient_1.5.7.zip https://downloads.indigorenderer.com/dist/cyberspace/substrata_webclient_1.5.7.zip \
 && unzip -o substrata_webclient_1.5.7.zip -d /server/server_data/webclient \
 && rm substrata_webclient_1.5.7.zip

# Сгенерировать самоподписанный TLS
RUN openssl req -new -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes \
  -subj "/O=Metasiberia/OU=Server/CN=localhost" \
  -out /server/server_data/MyCertificate.crt -keyout /server/server_data/MyKey.key

# Копируем наши конфиги/правки (если есть в репо)
COPY server/server_data/substrata_server_config.xml /server/server_data/substrata_server_config.xml

EXPOSE 10000

# В дистрибутиве бинарник называется 'server' (без .exe)
CMD ["/server/server"]
# Entrypoint: подставляем PORT от Render и запускаем сервер
COPY entrypoint.sh /entrypoint.sh
RUN apt-get update && apt-get install -y dos2unix && dos2unix /entrypoint.sh && chmod +x /entrypoint.sh
ENV PORT=10000
CMD ["/entrypoint.sh"]
# --- Entrypoint fix ---
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENV PORT=10000
ENTRYPOINT ["/entrypoint.sh"]
# --- Entrypoint for Render ---
COPY entrypoint.sh /entrypoint.sh
RUN apt-get update && apt-get install -y dos2unix && dos2unix /entrypoint.sh && chmod 755 /entrypoint.sh
ENV PORT=10000
ENTRYPOINT ["/entrypoint.sh"]
# --- Locate and move Substrata binary to /server ---
RUN set -eux; \
    BIN_PATH=$(find /server -maxdepth 3 -type f -name server | head -n 1); \
    if [ -z "$BIN_PATH" ]; then echo "Substrata server binary not found"; exit 1; fi; \
    mv "$BIN_PATH" /server/server; \
    chmod +x /server/server
# --- Locate Substrata binary and place to /server/server ---
RUN set -eux; \
    BIN_PATH=$(find /server -maxdepth 3 -type f -name server | head -n 1 || true); \
    if [ -z "$BIN_PATH" ]; then echo "Substrata server binary not found"; exit 1; fi; \
    mv "$BIN_PATH" /server/server && chmod +x /server/server

# --- Prepare persistent server_state_dir expected by binary ---
RUN set -eux; \
    STATE_DIR=/root/cyberspace_server_state; \
    mkdir -p "$STATE_DIR" "$STATE_DIR/dist_resources" "$STATE_DIR/webclient" /var/www/cyberspace/screenshots; \
    # Переносим конфиг/серты, если мы их положили в /server/server_data
    if [ -f /server/server_data/substrata_server_config.xml ]; then mv /server/server_data/substrata_server_config.xml "$STATE_DIR/substrata_server_config.xml"; fi; \
    if [ -f /server/server_data/MyCertificate.crt ]; then mv /server/server_data/MyCertificate.crt "$STATE_DIR/MyCertificate.crt"; fi; \
    if [ -f /server/server_data/MyKey.key ]; then mv /server/server_data/MyKey.key "$STATE_DIR/MyKey.key"; fi; \
    # Ресурсы и веб-клиент
    if [ -d /server/server_data/dist_resources ]; then cp -r /server/server_data/dist_resources/* "$STATE_DIR/dist_resources/" || true; fi; \
    if [ -d /server/server_data/webclient ]; then cp -r /server/server_data/webclient/* "$STATE_DIR/webclient/" || true; fi; \
    # Правим путь webclient_dir в конфиге, если файл существует
    if [ -f "$STATE_DIR/substrata_server_config.xml" ]; then sed -i "s#<webclient_dir>.*</webclient_dir>#<webclient_dir>/root/cyberspace_server_state/webclient</webclient_dir>#" "$STATE_DIR/substrata_server_config.xml"; fi

# --- Ensure entrypoint is POSIX and executable ---
RUN apt-get update && apt-get install -y dos2unix && dos2unix /entrypoint.sh && chmod 755 /entrypoint.sh

# --- Render uses dynamic $PORT; advertise 10000 by default ---
EXPOSE 10000
ENV PORT=10000

# --- Start ---
ENTRYPOINT ["/entrypoint.sh"]
# --- Robust: locate Substrata binary and ensure /server/server exists ---
RUN set -eux; \
    BIN_PATH=$(find /server -maxdepth 4 -type f -name server | head -n 1 || true); \
    if [ -z "$BIN_PATH" ]; then echo "Substrata server binary not found"; exit 1; fi; \
    if [ "$BIN_PATH" != "/server/server" ]; then mv "$BIN_PATH" /server/server; fi; \
    chmod +x /server/server
