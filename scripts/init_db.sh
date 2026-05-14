#!/bin/bash
###############################################################################
# Database Initialization Script for Twilight E-Commerce Platform
# Creates SQLite database and all required tables
###############################################################################

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DB_DIR="$PROJECT_ROOT/database"
DB_FILE="$DB_DIR/twilight.db"

# Create database directory if it doesn't exist
mkdir -p "$DB_DIR"

# Initialize database and create tables
sqlite3 "$DB_FILE" <<EOF
-- Users table (both admin and customers)
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
);

-- Products table
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
);

-- Cart table (temporary storage until checkout)
CREATE TABLE IF NOT EXISTS cart (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE(user_id, product_id)
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    total_price REAL NOT NULL,
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    shipping_address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Order items table (products in each order)
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
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_cart_user ON cart(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- Insert default admin user (password: admin123 - SHA256 hashed)
-- Password hash for 'admin123': 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
INSERT OR IGNORE INTO users (username, password, email, role, full_name) 
VALUES ('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin@twilight.com', 'admin', 'Administrator');

-- Insert sample products
INSERT OR IGNORE INTO products (name, description, price, stock, category, image) VALUES
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
('Crochet Cushion Cover', 'Soft crochet cushion cover with geometric patterns. Includes insert.', 28.99, 45, 'Flower', 'cushion1.jpg');

EOF

# Check if database was created successfully
if [ -f "$DB_FILE" ]; then
    echo "{\"success\": true, \"message\": \"Database initialized successfully\", \"database\": \"$DB_FILE\"}"
    chmod 664 "$DB_FILE"
else
    echo "{\"success\": false, \"message\": \"Failed to create database\"}"
    exit 1
fi
