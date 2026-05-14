#!/usr/bin/env python3
"""
API Handler for Twilight E-Commerce Platform
Handles login, register, products, cart, and orders
"""

import sys
import json
import sqlite3
import hashlib
import os
from pathlib import Path
from datetime import datetime, timedelta
import uuid

# Project root
SCRIPT_DIR = Path(__file__).parent
DB_FILE = SCRIPT_DIR / 'database' / 'twilight.db'
SESSION_DIR = SCRIPT_DIR / 'sessions'

# Create sessions directory
SESSION_DIR.mkdir(exist_ok=True)

def hash_password(password):
    """Hash password using SHA-256"""
    return hashlib.sha256(password.encode()).hexdigest()

def generate_token():
    """Generate a random session token"""
    return str(uuid.uuid4()).replace('-', '') + str(uuid.uuid4()).replace('-', '')

def create_session(user_id, username, role):
    """Create a session file"""
    token = generate_token()
    session_file = SESSION_DIR / f"{token}.session"
    
    session_data = {
        'user_id': user_id,
        'username': username,
        'role': role,
        'created': datetime.now().isoformat()
    }
    
    with open(session_file, 'w') as f:
        json.dump(session_data, f)
    
    return token

def json_response(success, **kwargs):
    """Return a JSON response"""
    response = {'success': success}
    response.update(kwargs)
    print(json.dumps(response))

def parse_post_data(body):
    """Parse URL-encoded POST data"""
    params = {}
    if body:
        for pair in body.split('&'):
            if '=' in pair:
                key, value = pair.split('=', 1)
                params[key] = value.replace('+', ' ')
    return params

def login():
    """Handle login request"""
    try:
        body = sys.stdin.read()
        params = parse_post_data(body)
        
        username = params.get('username', '').strip()
        password = params.get('password', '').strip()
        
        if not username or not password:
            json_response(False, error="Username and password are required", message="Login failed")
            return
        
        # Hash the password
        password_hash = hash_password(password)
        
        # Query database
        conn = sqlite3.connect(str(DB_FILE))
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute(
            'SELECT id, username, role, email, full_name FROM users WHERE username = ? AND password = ?',
            (username, password_hash)
        )
        
        user = cursor.fetchone()
        conn.close()
        
        if not user:
            json_response(False, error="Invalid username or password", message="Login failed")
            return
        
        # Create session
        token = create_session(user['id'], user['username'], user['role'])
        
        json_response(True, 
            message="Login successful",
            token=token,
            user={
                'id': user['id'],
                'username': user['username'],
                'role': user['role'],
                'email': user['email'],
                'full_name': user['full_name']
            }
        )
    except Exception as e:
        json_response(False, error=str(e), message="Server error")

def register():
    """Handle registration request"""
    try:
        body = sys.stdin.read()
        params = parse_post_data(body)
        
        username = params.get('username', '').strip()
        email = params.get('email', '').strip()
        password = params.get('password', '').strip()
        full_name = params.get('full_name', '').strip()
        
        if not username or not email or not password:
            json_response(False, error="Username, email, and password are required")
            return
        
        # Hash password
        password_hash = hash_password(password)
        
        # Insert into database
        try:
            conn = sqlite3.connect(str(DB_FILE))
            cursor = conn.cursor()
            
            cursor.execute(
                'INSERT INTO users (username, password, email, role, full_name) VALUES (?, ?, ?, ?, ?)',
                (username, password_hash, email, 'customer', full_name)
            )
            
            conn.commit()
            conn.close()
            
            json_response(True, message="Registration successful")
        except sqlite3.IntegrityError:
            json_response(False, error="Username or email already exists")
    except Exception as e:
        json_response(False, error=str(e))

def show_products():
    """Get products from database"""
    try:
        conn = sqlite3.connect(str(DB_FILE))
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        
        cursor.execute('SELECT id, name, description, price, stock, category, image FROM products')
        products = [dict(row) for row in cursor.fetchall()]
        
        conn.close()
        
        json_response(True, products=products, message="Products retrieved")
    except Exception as e:
        json_response(False, error=str(e))

def add_product():
    """Add a new product (admin only)"""
    try:
        body = sys.stdin.read()
        params = parse_post_data(body)
        
        name = params.get('name', '').strip()
        description = params.get('description', '').strip()
        price = float(params.get('price', 0))
        stock = int(params.get('stock', 0))
        category = params.get('category', '').strip()
        image = params.get('image', '').strip()
        
        conn = sqlite3.connect(str(DB_FILE))
        cursor = conn.cursor()
        
        cursor.execute(
            'INSERT INTO products (name, description, price, stock, category, image) VALUES (?, ?, ?, ?, ?, ?)',
            (name, description, price, stock, category, image)
        )
        
        conn.commit()
        conn.close()
        
        json_response(True, message="Product added successfully")
    except Exception as e:
        json_response(False, error=str(e))

def cart_handler():
    """Handle cart operations"""
    try:
        body = sys.stdin.read()
        params = parse_post_data(body)
        
        operation = params.get('operation', '').strip()
        user_id = params.get('user_id', '').strip()
        product_id = params.get('product_id', '').strip()
        quantity = int(params.get('quantity', 1))
        
        conn = sqlite3.connect(str(DB_FILE))
        cursor = conn.cursor()
        
        if operation == 'add':
            cursor.execute(
                'INSERT OR REPLACE INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)',
                (user_id, product_id, quantity)
            )
        elif operation == 'remove':
            cursor.execute('DELETE FROM cart WHERE user_id = ? AND product_id = ?', (user_id, product_id))
        elif operation == 'get':
            cursor.execute('SELECT * FROM cart WHERE user_id = ?', (user_id,))
            items = cursor.fetchall()
            json_response(True, items=items)
            conn.close()
            return
        
        conn.commit()
        conn.close()
        
        json_response(True, message="Cart operation successful")
    except Exception as e:
        json_response(False, error=str(e))

def main():
    """Main API router"""
    if len(sys.argv) < 2:
        json_response(False, error="No action specified")
        return
    
    action = sys.argv[1]
    
    if action == 'login':
        login()
    elif action == 'register':
        register()
    elif action == 'show_products':
        show_products()
    elif action == 'add_product':
        add_product()
    elif action == 'cart_handler':
        cart_handler()
    else:
        json_response(False, error=f"Unknown action: {action}")

if __name__ == '__main__':
    main()
