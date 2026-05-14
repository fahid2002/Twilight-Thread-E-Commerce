#!/bin/bash
###############################################################################
# Server Launcher for Twilight E-Commerce Platform
# Starts a simple HTTP server with CGI support
###############################################################################

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
CGI_DIR="$PROJECT_ROOT/cgi-bin"
DB_FILE="$PROJECT_ROOT/database/twilight.db"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Twilight E-Commerce Platform${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if database exists, if not create it
if [ ! -f "$DB_FILE" ]; then
    echo -e "${YELLOW}Database not found. Initializing...${NC}"
    bash "$PROJECT_ROOT/scripts/init_db.sh"
    echo ""
fi

# Make all scripts executable
echo -e "${GREEN}Setting script permissions...${NC}"
chmod +x "$PROJECT_ROOT/scripts/"*.sh
chmod +x "$CGI_DIR/"*.sh
echo ""

# Display server information
echo -e "${GREEN}✓ Server Configuration:${NC}"
echo -e "  Frontend Directory: ${FRONTEND_DIR}"
echo -e "  CGI Directory: ${CGI_DIR}"
echo -e "  Database: ${DB_FILE}"
echo ""

echo -e "${GREEN}✓ Default Admin Account:${NC}"
echo -e "  Username: ${YELLOW}admin${NC}"
echo -e "  Password: ${YELLOW}admin123${NC}"
echo ""

# Choose port
PORT=8080
echo -e "${BLUE}Starting server on port ${PORT}...${NC}"
echo ""

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✓ Server is running!${NC}"
    echo -e "${GREEN}✓ Access the website at: ${YELLOW}http://localhost:${PORT}${NC}"
    echo -e "${GREEN}✓ Admin Panel: ${YELLOW}http://localhost:${PORT}/admin/dashboard.html${NC}"
    echo ""
    echo -e "${BLUE}Press Ctrl+C to stop the server${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    cd "$FRONTEND_DIR"
    
    # Create a simple Python CGI server
    python3 - <<EOF
import http.server
import socketserver
import os
import subprocess
from urllib.parse import parse_qs, urlparse

PORT = $PORT
CGI_DIR = "$CGI_DIR"

class CGIHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/cgi-bin/'):
            self.run_cgi()
        else:
            super().do_GET()
    
    def do_POST(self):
        if self.path.startswith('/cgi-bin/'):
            self.run_cgi()
        else:
            self.send_error(404, "Not Found")
    
    def run_cgi(self):
        # Parse the path
        parsed_path = urlparse(self.path)
        script_name = parsed_path.path.replace('/cgi-bin/', '')
        script_path = os.path.join(CGI_DIR, script_name)
        
        if not os.path.exists(script_path):
            self.send_error(404, "CGI script not found")
            return
        
        # Set up environment
        env = os.environ.copy()
        env['REQUEST_METHOD'] = self.command
        env['QUERY_STRING'] = parsed_path.query or ''
        env['CONTENT_TYPE'] = self.headers.get('Content-Type', '')
        
        # Read POST data if present
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length) if content_length > 0 else b''
        
        try:
            # Execute the CGI script
            process = subprocess.Popen(
                ['bash', script_path],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=env
            )
            
            stdout, stderr = process.communicate(input=post_data)
            
            # Send response
            self.send_response(200)
            
            # Parse headers from script output
            output = stdout.decode('utf-8', errors='ignore')
            headers_end = output.find('\n\n')
            
            if headers_end != -1:
                headers_part = output[:headers_end]
                body_part = output[headers_end+2:]
                
                for header_line in headers_part.split('\n'):
                    if ':' in header_line:
                        key, value = header_line.split(':', 1)
                        self.send_header(key.strip(), value.strip())
            else:
                body_part = output
                self.send_header('Content-Type', 'application/json')
            
            self.end_headers()
            self.wfile.write(body_part.encode('utf-8'))
            
        except Exception as e:
            self.send_error(500, f"CGI Error: {str(e)}")

with socketserver.TCPServer(("", PORT), CGIHTTPRequestHandler) as httpd:
    httpd.serve_forever()
EOF

elif command -v python &> /dev/null; then
    echo -e "${GREEN}✓ Server is running!${NC}"
    echo -e "${GREEN}✓ Access the website at: ${YELLOW}http://localhost:${PORT}${NC}"
    echo ""
    echo -e "${BLUE}Press Ctrl+C to stop the server${NC}"
    echo ""
    
    cd "$FRONTEND_DIR"
    python -m http.server $PORT

else
    echo -e "${YELLOW}Warning: Python not found${NC}"
    echo -e "Please install Python 3 to run the server"
    echo ""
    echo -e "Alternative: You can use any web server with CGI support"
    echo -e "Example with PHP built-in server:"
    echo -e "  cd $FRONTEND_DIR"
    echo -e "  php -S localhost:8080"
fi
