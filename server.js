#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 8080;
const FRONTEND_DIR = path.join(__dirname, 'frontend');
const API_HANDLER = path.join(__dirname, 'api_handler.py');

// MIME types
const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

const server = http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);

  // Handle API requests
  if (req.url.startsWith('/cgi-bin/api.sh')) {
    handleAPI(req, res);
    return;
  }

  // Parse URL to remove query string
  const urlPath = req.url.split('?')[0];
  
  // Serve static files
  let filePath = path.join(FRONTEND_DIR, urlPath === '/' ? 'index.html' : urlPath);
  const extname = String(path.extname(filePath)).toLowerCase();
  const contentType = mimeTypes[extname] || 'application/octet-stream';

  fs.readFile(filePath, (error, content) => {
    if (error) {
      if (error.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end('<h1>404 Not Found</h1>', 'utf-8');
      } else {
        res.writeHead(500);
        res.end(`Server Error: ${error.code}`, 'utf-8');
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

function handleAPI(req, res) {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const queryString = url.search.substring(1);
  const action = new URLSearchParams(queryString).get('action');

  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });

  req.on('end', () => {
    try {
      // Spawn Python API handler
      const pythonProcess = spawn('python', [API_HANDLER, action]);

      let output = '';
      let errorOutput = '';

      pythonProcess.stdout.on('data', (data) => {
        output += data.toString();
      });

      pythonProcess.stderr.on('data', (data) => {
        errorOutput += data.toString();
        console.error('Python Error:', data.toString());
      });

      pythonProcess.stdin.write(body);
      pythonProcess.stdin.end();

      pythonProcess.on('close', (code) => {
        try {
          // Try to parse as JSON
          const jsonMatch = output.match(/\{[\s\S]*\}/);
          const jsonResponse = jsonMatch ? jsonMatch[0] : output;

          res.writeHead(200, {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
          });
          res.end(jsonResponse);
        } catch (error) {
          console.error('Error processing response:', error);
          res.writeHead(500, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ success: false, message: 'Server error', error: error.message }));
        }
      });
    } catch (error) {
      console.error('API Error:', error.message);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, message: 'Server error', error: error.message }));
    }
  });
}

server.listen(PORT, () => {
  console.log('\n========================================');
  console.log('   Twilight E-Commerce Platform');
  console.log('========================================\n');
  console.log('✓ Server is running!');
  console.log(`✓ Access the website at: http://localhost:${PORT}`);
  console.log(`✓ Admin Panel: http://localhost:${PORT}/admin/dashboard.html\n`);
  console.log('✓ Default Admin Account:');
  console.log('  Username: admin');
  console.log('  Password: admin123\n');
  console.log('Press Ctrl+C to stop the server');
  console.log('========================================\n');
});
