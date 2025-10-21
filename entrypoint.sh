#!/usr/bin/env bash
set -e

# Запускаем простой HTTP сервер для Render
echo "Starting Metasiberia HTTP server for Render on port $PORT..."
exec python3 -c "
import os
import json
from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html = '''<!DOCTYPE html>
<html>
<head>
    <title>Metasiberia Substrata Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #1a1a1a; color: #fff; }
        .container { max-width: 900px; margin: 0 auto; }
        h1 { color: #4CAF50; }
        .status { background: #333; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .info { background: #2a2a2a; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .button { background: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 5px; }
        .button:hover { background: #45a049; }
        .warning { background: #ff6b6b; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .code { background: #444; padding: 10px; border-radius: 3px; font-family: monospace; }
    </style>
</head>
<body>
    <div class=\"container\">
        <h1>🚀 Metasiberia Substrata Server</h1>
        
        <div class=\"status\">
            <h2>✅ HTTP Server Status: Running</h2>
            <p>HTTP server is running successfully on Render.</p>
        </div>
        
        <div class=\"warning\">
            <h3>⚠️ Important Notice</h3>
            <p><strong>Substrata server requires HTTPS/TLS</strong>, but Render only supports HTTP for web services.</p>
            <p>For full Substrata functionality, you need to run the server locally or on a VPS with full control.</p>
        </div>
        
        <div class=\"info\">
            <h3>📋 Server Information</h3>
            <p><strong>Port:</strong> {port}</p>
            <p><strong>Protocol:</strong> HTTP (Render limitation)</p>
            <p><strong>Status:</strong> Active</p>
            <p><strong>Domain:</strong> metasiberia-server-v1.onrender.com</p>
        </div>
        
        <div class=\"info\">
            <h3>🔗 How to Connect to Substrata</h3>
            <p><strong>Option 1: Local Installation (Recommended)</strong></p>
            <ol>
                <li>Download Substrata client</li>
                <li>Run Substrata server locally with TLS</li>
                <li>Connect via <code>sub://localhost</code></li>
            </ol>
            
            <p><strong>Option 2: VPS Deployment</strong></p>
            <ol>
                <li>Use DigitalOcean, AWS, or Vultr</li>
                <li>Full control over HTTPS/TLS</li>
                <li>Complete Substrata functionality</li>
            </ol>
        </div>
        
        <div class=\"info\">
            <h3>🌐 Available Endpoints</h3>
            <p>• <a href=\"/status\">/status</a> - Server status (JSON)</p>
            <p>• <a href=\"/health\">/health</a> - Health check</p>
            <p>• <a href=\"/info\">/info</a> - Connection information</p>
        </div>
        
        <a href=\"/status\" class=\"button\">Server Status</a>
        <a href=\"/health\" class=\"button\">Health Check</a>
        <a href=\"/info\" class=\"button\">Connection Info</a>
    </div>
</body>
</html>'''.format(port=os.environ.get('PORT', 10000))
            
            self.wfile.write(html.encode())
            
        elif self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            status = {
                'server': 'Metasiberia HTTP Server',
                'status': 'running',
                'port': os.environ.get('PORT', 10000),
                'protocol': 'HTTP',
                'tls': False,
                'limitation': 'Render only supports HTTP for web services',
                'recommendation': 'Use local installation or VPS for full Substrata functionality'
            }
            
            self.wfile.write(json.dumps(status, indent=2).encode())
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK - HTTP server is running')
            
        elif self.path == '/info':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            info = {
                'substrata_connection': {
                    'local': 'sub://localhost',
                    'note': 'Requires local Substrata server with TLS'
                },
                'render_limitation': {
                    'issue': 'Substrata requires HTTPS, Render only supports HTTP',
                    'solution': 'Use local installation or VPS'
                },
                'alternatives': [
                    'Local installation with TLS certificates',
                    'VPS deployment (DigitalOcean, AWS, Vultr)',
                    'Dedicated server with full control'
                ]
            }
            
            self.wfile.write(json.dumps(info, indent=2).encode())
            
        else:
            self.send_response(404)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<h1>404 - Not Found</h1><a href=\"/\">Back to Home</a>')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 10000))
    server = HTTPServer(('0.0.0.0', port), SimpleHandler)
    print(f'HTTP server listening on 0.0.0.0:{port}')
    server.serve_forever()
"