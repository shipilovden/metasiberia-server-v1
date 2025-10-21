FROM ubuntu:22.04

# cache-bust to invalidate layers on every change
ARG CACHE_BUST=20251021296000

# Base tools
RUN apt-get update && apt-get install -y \
    dos2unix python3 \
 && rm -rf /var/lib/apt/lists/*

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod 755 /entrypoint.sh

# Render maps to $PORT (usually 10000)
EXPOSE 10000
ENV PORT=10000

ENTRYPOINT ["/entrypoint.sh"]