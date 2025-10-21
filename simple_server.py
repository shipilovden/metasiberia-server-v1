#!/usr/bin/env python3
import os
import subprocess
import threading
import time
import ssl
import urllib.request
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Metasiberia Substrata Server</title>
                <style>
                    body {{ font-family: Arial, sans-serif; margin: 40px; background: #1a1a1a; color: #fff; }}
                    .container {{ max-width: 800px; margin: 0 auto; }}
                    h1 {{ color: #4CAF50; }}
                    .status {{ background: #333; padding: 20px; border-radius: 8px; margin: 20px 0; }}
                    .info {{ background: #2a2a2a; padding: 15px; border-radius: 5px; margin: 10px 0; }}
                    .button {{ background: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 5px; }}
                    .button:hover {{ background: #45a049; }}
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>🚀 Metasiberia Substrata Server</h1>
                    
                    <div class="status">
                        <h2>✅ Server Status: Running</h2>
                        <p>Substrata server is running in the background with TLS support.</p>
                    </div>
                    
                    <div class="info">
                        <h3>📋 Server Information</h3>
                        <p><strong>Port:</strong> {port}</p>
                        <p><strong>Protocol:</strong> HTTPS (TLS)</p>
                        <p><strong>Status:</strong> Active</p>
                    </div>
                    
                    <div class="info">
                        <h3>🔗 Connection Instructions</h3>
                        <p>To connect to this Substrata server:</p>
                        <ol>
                            <li>Open Substrata client</li>
                            <li>Enter: <code>sub://metasiberia-server-v1.onrender.com</code></li>
                            <li>Or: <code>sub://metasiberia-server-v1.onrender.com:7600</code></li>
                        </ol>
                    </div>
                    
                    <div class="info">
                        <h3>🌐 Web Interface</h3>
                        <p>Web interface is available at: <code>https://metasiberia-server-v1.onrender.com</code></p>
                        <p><em>Note: You may need to accept the self-signed certificate.</em></p>
                    </div>
                    
                    <a href="/status" class="button">Server Status</a>
                    <a href="/health" class="button">Health Check</a>
                </div>
            </body>
            </html>
            """.format(port=os.environ.get('PORT', 10000))
            
            self.wfile.write(html.encode())
            
        elif self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            status = {
                "server": "Metasiberia Substrata Server",
                "status": "running",
                "port": os.environ.get('PORT', 10000),
                "protocol": "HTTPS",
                "tls": True,
                "substrata_port": 7600,
                "domain": "metasiberia-server-v1.onrender.com"
            }
            
            self.wfile.write(json.dumps(status, indent=2).encode())
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK - Substrata server is running')
            
        else:
            # Пытаемся перенаправить на Substrata сервер
            try:
                # Создаем SSL контекст без проверки сертификата
                ssl_context = ssl.create_default_context()
                ssl_context.check_hostname = False
                ssl_context.verify_mode = ssl.CERT_NONE
                
                # Перенаправляем на Substrata сервер
                substrata_url = f"https://localhost:7600{self.path}"
                req = urllib.request.Request(substrata_url)
                
                with urllib.request.urlopen(req, context=ssl_context) as response:
                    self.send_response(response.status)
                    for header, value in response.headers.items():
                        self.send_header(header, value)
                    self.end_headers()
                    self.wfile.write(response.read())
                    
            except Exception as e:
                self.send_error(500, f"Proxy error: {str(e)}")

def start_substrata_server():
    """Запускаем Substrata сервер в фоне"""
    try:
        print("Starting Substrata server in background...")
        # Запускаем Substrata сервер на порту 7600
        subprocess.Popen(['/server/server'], 
                        env={**os.environ, 'PORT': '7600'})
        print("Substrata server started on port 7600")
    except Exception as e:
        print(f"Failed to start Substrata server: {e}")

def start_http_server():
    """Запускаем HTTP сервер для Render"""
    port = int(os.environ.get('PORT', 10000))
    server = HTTPServer(('0.0.0.0', port), SimpleHandler)
    print(f"HTTP server listening on 0.0.0.0:{port}")
    server.serve_forever()

if __name__ == '__main__':
    # Запускаем Substrata сервер в фоне
    substrata_thread = threading.Thread(target=start_substrata_server)
    substrata_thread.daemon = True
    substrata_thread.start()
    
    # Ждем немного, чтобы Substrata сервер запустился
    time.sleep(5)
    
    # Запускаем HTTP сервер для Render
    start_http_server()
