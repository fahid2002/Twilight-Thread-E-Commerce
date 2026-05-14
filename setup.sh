#!/bin/bash
###############################################################################
# Quick Start Script for Twilight E-Commerce Platform
###############################################################################

clear
echo "================================================"
echo "  Twilight E-Commerce Platform - Quick Start"
echo "================================================"
echo ""

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for required dependencies
echo "Checking dependencies..."

# Check for bash
if ! command -v bash &> /dev/null; then
    echo "❌ Bash not found. Please install Bash."
    exit 1
fi
echo "✓ Bash found"

# Check for sqlite3
if ! command -v sqlite3 &> /dev/null; then
    echo "❌ SQLite3 not found. Please install SQLite3."
    echo "   Ubuntu/Debian: sudo apt-get install sqlite3"
    echo "   macOS: brew install sqlite3"
    echo "   Windows: Download from https://www.sqlite.org/download.html"
    exit 1
fi
echo "✓ SQLite3 found"

# Check for python3
if ! command -v python3 &> /dev/null; then
    echo "⚠️  Python3 not found. Server may not start properly."
    echo "   Please install Python 3.x for the development server."
else
    echo "✓ Python3 found"
fi

echo ""
echo "All dependencies checked!"
echo ""

# Make scripts executable
echo "Setting permissions..."
chmod +x "$PROJECT_ROOT/run.sh"
chmod +x "$PROJECT_ROOT/scripts/"*.sh
chmod +x "$PROJECT_ROOT/cgi-bin/"*.sh
echo "✓ Permissions set"
echo ""

# Initialize database if it doesn't exist
if [ ! -f "$PROJECT_ROOT/database/twilight.db" ]; then
    echo "Initializing database..."
    bash "$PROJECT_ROOT/scripts/init_db.sh"
    echo ""
fi

echo "================================================"
echo "  Setup Complete!"
echo "================================================"
echo ""
echo "To start the server, run:"
echo "  bash run.sh"
echo ""
echo "Or simply:"
echo "  ./run.sh"
echo ""
echo "Default Admin Credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "================================================"
