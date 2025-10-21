#!/usr/bin/env bash
set -e

# Запускаем простой HTTP сервер для Render
echo "Starting simple HTTP server for Render on port $PORT..."
exec python3 /simple_server.py