#!/usr/bin/env python3
"""
Database initialization script for Twilight E-Commerce Platform
Creates SQLite database with all tables and default admin user
"""

import sqlite3
import os
import hashlib
from pathlib import Path

# Define paths
SCRIPT_DIR = Path(__file__).parent
DB_DIR = SCRIPT_DIR / 'database'
DB_FILE = DB_DIR / 'twilight.db'

# Create database directory if it doesn't exist
DB_DIR.mkdir(exist_ok=True)

def hash_password(password):
    """Hash password using SHA-256"""
    return hashlib.sha256(password.encode()).hexdigest()

def init_database():
    """Initialize database with all tables"""
    try:
        conn = sqlite3.connect(str(DB_FILE))
        cursor = conn.cursor()
        
        # Create users table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                password TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                role TEXT NOT NULL CHECK(role IN ('admin', 'customer')),
                full_name TEXT,
                phone TEXT,
                address TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Create products table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
                price REAL NOT NULL CHECK(price >= 0),
                stock INTEGER NOT NULL DEFAULT 0 CHECK(stock >= 0),
                category TEXT,
                image TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Create cart table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS cart (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL CHECK(quantity > 0),
                added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
                UNIQUE(user_id, product_id)
            )
        ''')
        
        # Create orders table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                total_price REAL NOT NULL,
                status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
                shipping_address TEXT,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        ''')
        
        # Create order_items table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                product_name TEXT NOT NULL,
                quantity INTEGER NOT NULL CHECK(quantity > 0),
                price REAL NOT NULL,
                subtotal REAL NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
                FOREIGN KEY (product_id) REFERENCES products(id)
            )
        ''')
        
        # Create indexes
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_products_category ON products(category)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_cart_user ON cart(user_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id)')
        
        # Insert default admin user
        admin_password_hash = hash_password('admin123')
        cursor.execute('''
            INSERT OR IGNORE INTO users (username, password, email, role, full_name) 
            VALUES (?, ?, ?, ?, ?)
        ''', ('admin', admin_password_hash, 'admin@twilight.com', 'admin', 'Administrator'))
        
        # Insert sample products
        sample_products = [
            ('Handwoven Silk Scarf', 'Luxurious handwoven silk scarf with intricate patterns. Perfect for any occasion.', 45.99, 25, 'Key Ring', 'scarf1.jpg'),
            ('Ceramic Tea Set', 'Beautiful handcrafted ceramic tea set with floral designs. Includes teapot and 4 cups.', 89.99, 15, 'Home & Kitchen', 'teaset1.jpg'),
            ('Embroidered Tote Bag', 'Eco-friendly canvas tote bag with beautiful hand embroidery.', 32.50, 40, 'Bags', 'tote1.jpg'),
            ('Macrame Wall Hanging', 'Elegant macrame wall hanging, perfect for bohemian home decor.', 65.00, 20, 'Flower', 'macrame1.jpg'),
            ('Hand-painted Jewelry Box', 'Wooden jewelry box with intricate hand-painted floral motifs.', 55.00, 18, 'Name Design', 'jewelrybox1.jpg'),
            ('Knitted Wool Blanket', 'Cozy handknitted wool blanket in neutral colors. Perfect for cold evenings.', 120.00, 12, 'Neck Design', 'blanket1.jpg'),
            ('Beaded Necklace Set', 'Handmade beaded necklace with matching earrings. Unique artisan design.', 38.99, 30, 'Doormat', 'necklace1.jpg'),
            ('Pottery Vase', 'Hand-thrown ceramic vase with glazed finish. Great for fresh or dried flowers.', 42.00, 22, 'Flower', 'vase1.jpg'),
            ('Woven Basket Set', 'Set of 3 handwoven baskets in different sizes. Perfect for organization.', 58.50, 16, 'Name Design', 'basket1.jpg'),
            ('Quilted Table Runner', 'Beautiful quilted table runner with traditional patterns.', 48.00, 28, 'Neck Design', 'runner1.jpg'),
            ('Leather Journal', 'Handcrafted leather journal with handmade paper. Perfect for writing or sketching.', 36.00, 35, 'Stationery', 'journal1.jpg'),
            ('Crochet Cushion Cover', 'Soft crochet cushion cover with geometric patterns. Includes insert.', 28.99, 45, 'Flower', 'cushion1.jpg'),
        ]
        
        for product in sample_products:
            cursor.execute('''
                INSERT OR IGNORE INTO products (name, description, price, stock, category, image) 
                VALUES (?, ?, ?, ?, ?, ?)
            ''', product)
        
        conn.commit()
        conn.close()
        
        print(f"✓ Database initialized successfully at {DB_FILE}")
        print(f"✓ Admin user created: username='admin', password='admin123'")
        print(f"✓ {len(sample_products)} sample products inserted")
        return True
        
    except Exception as e:
        print(f"✗ Error initializing database: {e}")
        return False

if __name__ == '__main__':
    init_database()
