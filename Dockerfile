FROM ubuntu:22.04

# cache-bust to invalidate layers on every change
ARG CACHE_BUST=20251021195000

# Base tools
RUN apt-get update && apt-get install -y \
    wget unzip ca-certificates openssl dos2unix \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /server

# 1) Download & extract Substrata Server (Linux)
RUN set -eux; \
    wget -O SubstrataServer_v1.5.7.tar.gz https://downloads.indigorenderer.com/dist/cyberspace/SubstrataServer_v1.5.7.tar.gz; \
    tar -xzf SubstrataServer_v1.5.7.tar.gz; \
    rm SubstrataServer_v1.5.7.tar.gz

# 2) Ensure /server/server exists (no "mv same file")
RUN set -eux; \
    BIN_PATH=$(find /server -maxdepth 4 -type f -name server | head -n 1); \
    if [ -z "$BIN_PATH" ]; then echo "Substrata server binary not found"; exit 1; fi; \
    if [ "$BIN_PATH" != "/server/server" ]; then cp "$BIN_PATH" /server/server; fi; \
    chmod +x /server/server

# 3) Prepare server_state_dir
ENV STATE_DIR=/root/cyberspace_server_state
RUN set -eux; \
    mkdir -p "$STATE_DIR" "$STATE_DIR/dist_resources" "$STATE_DIR/webclient" /var/www/cyberspace/screenshots

# 4) Dist resources + webclient
RUN set -eux; \
    wget -O /tmp/server_dist_files.zip https://downloads.indigorenderer.com/dist/cyberspace/server_dist_files.zip; \
    unzip -o /tmp/server_dist_files.zip -d "$STATE_DIR"; rm /tmp/server_dist_files.zip; \
    wget -O /tmp/substrata_webclient_1.5.7.zip https://downloads.indigorenderer.com/dist/cyberspace/substrata_webclient_1.5.7.zip; \
    unzip -o /tmp/substrata_webclient_1.5.7.zip -d "$STATE_DIR/webclient"; rm /tmp/substrata_webclient_1.5.7.zip

# 5) Self-signed TLS
RUN set -eux; \
    openssl req -new -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes \
      -subj "/O=Metasiberia/OU=Server/CN=localhost" \
      -out "$STATE_DIR/MyCertificate.crt" -keyout "$STATE_DIR/MyKey.key"

# 6) Config: use repo seed if present, else minimal default
COPY server/server_data/substrata_server_config.xml /server/_seed_config.xml
RUN set -eux; \
    if [ -f /server/_seed_config.xml ]; then \
      mv /server/_seed_config.xml "$STATE_DIR/substrata_server_config.xml"; \
    else \
      printf '%s\n' \
        '<server_config>' \
        "  <webclient_dir>$STATE_DIR/webclient</webclient_dir>" \
        '  <tls_cert_file>MyCertificate.crt</tls_cert_file>' \
        '  <tls_key_file>MyKey.key</tls_key_file>' \
        '  <port>10000</port>' \
        '</server_config>' \
        > "$STATE_DIR/substrata_server_config.xml"; \
    fi

# 7) Bust cache right before COPY entrypoint.sh
ARG CACHE_BUST
RUN echo "CACHE_BUST=$CACHE_BUST"

# 8) Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod 755 /entrypoint.sh

# Render maps to $PORT (usually 10000)
EXPOSE 10000
ENV PORT=10000
ENV STATE_DIR=/root/cyberspace_server_state

ENTRYPOINT ["/entrypoint.sh"]
