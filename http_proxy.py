#!/usr/bin/env python3
import os
import socket
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.request
import urllib.parse

class ProxyHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # Перенаправляем запрос на Substrata сервер
            substrata_url = f"http://localhost:7600{self.path}"
            response = urllib.request.urlopen(substrata_url)
            
            # Копируем заголовки ответа
            for header, value in response.headers.items():
                self.send_header(header, value)
            self.end_headers()
            
            # Копируем тело ответа
            self.wfile.write(response.read())
            
        except Exception as e:
            self.send_error(500, f"Proxy error: {str(e)}")
    
    def do_POST(self):
        self.do_GET()
    
    def log_message(self, format, *args):
        # Отключаем логирование для чистоты
        pass

def start_proxy():
    port = int(os.environ.get('PORT', 10000))
    server = HTTPServer(('0.0.0.0', port), ProxyHandler)
    print(f"HTTP Proxy listening on 0.0.0.0:{port}")
    server.serve_forever()

if __name__ == '__main__':
    start_proxy()
