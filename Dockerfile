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
