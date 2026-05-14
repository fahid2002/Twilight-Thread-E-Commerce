@echo off
REM Twilight E-Commerce Platform - Windows Launcher
REM This batch file runs the server on Windows

echo ================================================
echo   Twilight E-Commerce Platform
echo ================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.x from https://www.python.org/
    pause
    exit /b 1
)

echo Python found!
echo.

REM Initialize database if needed
if not exist "database\twilight.db" (
    echo Initializing database...
    python init_database.py
    echo.
)

echo Starting server on port 8080...
echo.
echo Access the website at: http://localhost:8080
echo Admin Panel: http://localhost:8080/admin/dashboard.html
echo.
echo Default Admin Credentials:
echo   Username: admin
echo   Password: admin123
echo.
echo Press Ctrl+C to stop the server
echo ================================================
echo.

node server.js
