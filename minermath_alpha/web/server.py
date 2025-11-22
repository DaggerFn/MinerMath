#!/usr/bin/env python3

import http.server
import socketserver
import ssl
import sys
import os
from pathlib import Path

PORT = 8080
BIND_ADDRESS = "0.0.0.0"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add headers required for Godot Web (workaround para não precisar HTTPS)
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def log_message(self, format, *args):
        print(f"[{self.client_address[0]}] {format % args}")

if __name__ == "__main__":
    os.chdir(Path(__file__).parent)
    
    with socketserver.TCPServer((BIND_ADDRESS, PORT), MyHTTPRequestHandler) as httpd:
        print(f"🎮 Godot Web Server rodando!")
        print(f"📍 Local: http://localhost:{PORT}/MinerMath_Alpha.html")
        
        try:
            import socket
            hostname = socket.gethostname()
            ip = socket.gethostbyname(hostname)
            print(f"🌐 Rede:  http://{ip}:{PORT}/MinerMath_Alpha.html")
        except:
            pass
        
        print(f"\nPressione Ctrl+C para parar o servidor\n")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n✓ Servidor encerrado")
            sys.exit(0)
