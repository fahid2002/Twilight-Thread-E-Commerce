#!/bin/bash
###############################################################################
# Place Order Script for Twilight E-Commerce Platform
# Handles direct product purchase orders
###############################################################################

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Get database path
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DB_FILE="$PROJECT_ROOT/database/twilight.db"
SESSIONS_DIR="$PROJECT_ROOT/sessions"

# Set content type
echo "Content-Type: application/json"
echo ""

# Read POST data
read -r POST_DATA

# Parse POST parameters
token=$(echo "$POST_DATA" | grep -oP 'token=\K[^&]+' | head -1)
product_id=$(echo "$POST_DATA" | grep -oP 'product_id=\K[^&]+' | head -1)
quantity=$(echo "$POST_DATA" | grep -oP 'quantity=\K[^&]+' | head -1)
product_name=$(echo "$POST_DATA" | grep -oP 'product_name=\K[^&]+' | head -1 | sed 's/%20/ /g' | sed 's/%26/\&/g')
price=$(echo "$POST_DATA" | grep -oP 'price=\K[^&]+' | head -1)
total_price=$(echo "$POST_DATA" | grep -oP 'total_price=\K[^&]+' | head -1)

# Validate required fields
if [ -z "$token" ] || [ -z "$product_id" ] || [ -z "$quantity" ]; then
    echo "{\"success\": false, \"error\": \"Missing required fields\"}"
    exit 1
fi

# Verify session token
if [ ! -f "$SESSIONS_DIR/${token}.session" ]; then
    echo "{\"success\": false, \"error\": \"Invalid or expired session\"}"
    exit 1
fi

# Get user ID from session
user_id=$(cat "$SESSIONS_DIR/${token}.session" | grep -oP 'user_id=\K[0-9]+')

if [ -z "$user_id" ]; then
    echo "{\"success\": false, \"error\": \"Invalid session data\"}"
    exit 1
fi

# Validate product exists and has enough stock
product_check=$(sqlite3 "$DB_FILE" "SELECT id, price, stock, name FROM products WHERE id = $product_id;")

if [ -z "$product_check" ]; then
    echo "{\"success\": false, \"error\": \"Product not found\"}"
    exit 1
fi

# Parse product data
IFS='|' read -r pid product_price stock db_product_name <<< "$product_check"

# Validate stock
if [ "$stock" -lt "$quantity" ]; then
    echo "{\"success\": false, \"error\": \"Insufficient stock. Only $stock available.\"}"
    exit 1
fi

# Use database values if not provided
if [ -z "$price" ]; then
    price=$product_price
fi

if [ -z "$product_name" ]; then
    product_name="$db_product_name"
fi

# Calculate total if not provided
if [ -z "$total_price" ]; then
    total_price=$(echo "$price * $quantity" | bc -l)
fi

# Get user info for shipping address
user_info=$(sqlite3 "$DB_FILE" "SELECT address, full_name FROM users WHERE id = $user_id;")
IFS='|' read -r address full_name <<< "$user_info"

if [ -z "$address" ]; then
    address="No address provided"
fi

# Begin transaction
sqlite3 "$DB_FILE" <<EOF
BEGIN TRANSACTION;

-- Create the order
INSERT INTO orders (user_id, total_price, status, shipping_address, created_at)
VALUES ($user_id, $total_price, 'pending', '$address', datetime('now'));

-- Get the order ID
-- Store in a temporary table since we can't use variables directly
CREATE TEMP TABLE IF NOT EXISTS temp_order_id (id INTEGER);
DELETE FROM temp_order_id;
INSERT INTO temp_order_id SELECT last_insert_rowid();

-- Insert order item
INSERT INTO order_items (order_id, product_id, product_name, quantity, price, subtotal)
SELECT id, $product_id, '$product_name', $quantity, $price, $total_price
FROM temp_order_id;

-- Update product stock
UPDATE products 
SET stock = stock - $quantity,
    updated_at = datetime('now')
WHERE id = $product_id;

-- Get the order ID for response
SELECT id FROM temp_order_id;

COMMIT;
EOF

# Check if order was created successfully
if [ $? -eq 0 ]; then
    # Get the order ID from the last output
    order_id=$(sqlite3 "$DB_FILE" "SELECT MAX(id) FROM orders WHERE user_id = $user_id;")
    
    echo "{\"success\": true, \"message\": \"Order placed successfully\", \"order_id\": $order_id, \"total\": $total_price}"
else
    echo "{\"success\": false, \"error\": \"Failed to place order\"}"
    exit 1
fi
