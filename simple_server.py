#!/usr/bin/env python3
import os
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
                        <p>HTTP server is running successfully on Render.</p>
                    </div>
                    
                    <div class="info">
                        <h3>📋 Server Information</h3>
                        <p><strong>Port:</strong> {port}</p>
                        <p><strong>Protocol:</strong> HTTP</p>
                        <p><strong>Status:</strong> Active</p>
                    </div>
                    
                    <div class="info">
                        <h3>🔗 Connection Instructions</h3>
                        <p>This is a simplified HTTP server for Render deployment.</p>
                        <p>For full Substrata functionality, you would need to run the server locally with proper TLS configuration.</p>
                    </div>
                    
                    <div class="info">
                        <h3>🌐 Available Endpoints</h3>
                        <p>• <a href="/status">/status</a> - Server status (JSON)</p>
                        <p>• <a href="/health">/health</a> - Health check</p>
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
                "server": "Metasiberia HTTP Server",
                "status": "running",
                "port": os.environ.get('PORT', 10000),
                "protocol": "HTTP",
                "tls": False,
                "note": "Simplified HTTP server for Render deployment"
            }
            
            self.wfile.write(json.dumps(status, indent=2).encode())
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK - HTTP server is running')
            
        else:
            # Показываем 404 для неизвестных путей
            self.send_response(404)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>404 - Not Found</title>
                <style>
                    body {{ font-family: Arial, sans-serif; margin: 40px; background: #1a1a1a; color: #fff; text-align: center; }}
                    h1 {{ color: #ff6b6b; }}
                    a {{ color: #4CAF50; }}
                </style>
            </head>
            <body>
                <h1>404 - Page Not Found</h1>
                <p>The requested page was not found.</p>
                <a href="/">← Back to Home</a>
            </body>
            </html>
            """
            
            self.wfile.write(html.encode())

if __name__ == "__main__":
    # Запускаем только HTTP сервер для Render
    port = int(os.environ.get('PORT', 10000))
    server = HTTPServer(('0.0.0.0', port), SimpleHandler)
    print(f"HTTP server listening on 0.0.0.0:{port}")
    server.serve_forever()