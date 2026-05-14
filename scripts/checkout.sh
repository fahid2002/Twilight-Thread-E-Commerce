#!/bin/bash
###############################################################################
# Checkout Script for Twilight E-Commerce Platform
# Processes orders and manages inventory
###############################################################################

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Set content type for CGI
echo "Content-Type: application/json"
echo ""

# Read POST data
if [ "$REQUEST_METHOD" = "POST" ]; then
    read -r POST_DATA
else
    POST_DATA="$1"
fi

# Parse input parameters
token=""
shipping_address=""

IFS='&'
for param in $POST_DATA; do
    key="${param%%=*}"
    value="${param#*=}"
    value=$(urldecode "$value")
    
    case "$key" in
        token) token="$value" ;;
        shipping_address) shipping_address="$value" ;;
    esac
done

# Validate session
if [ -z "$token" ]; then
    json_error "Authentication required"
    exit 1
fi

if ! validate_session "$token"; then
    json_error "Invalid or expired session"
    exit 1
fi

user_id=$(get_user_id_from_session "$token")

# Validate shipping address
if [ -z "$shipping_address" ]; then
    json_error "Shipping address is required"
    exit 1
fi

shipping_address=$(sanitize_input "$shipping_address")

# Get cart items
cart_items=$(sqlite3 "$DB_FILE" "SELECT c.product_id, c.quantity, p.price, p.stock, p.name 
                                  FROM cart c 
                                  JOIN products p ON c.product_id = p.id 
                                  WHERE c.user_id=$user_id;")

if [ -z "$cart_items" ]; then
    json_error "Cart is empty"
    exit 1
fi

# Verify stock availability for all items
stock_errors=""
while IFS='|' read -r product_id quantity price stock name; do
    if [ "$stock" -lt "$quantity" ]; then
        stock_errors="${stock_errors}Product '$name' has insufficient stock (available: $stock, requested: $quantity). "
    fi
done <<< "$cart_items"

if [ -n "$stock_errors" ]; then
    json_error "$stock_errors"
    exit 1
fi

# Calculate total price
total_price=$(sqlite3 "$DB_FILE" "SELECT SUM(p.price * c.quantity) 
                                   FROM cart c 
                                   JOIN products p ON c.product_id = p.id 
                                   WHERE c.user_id=$user_id;")

# Begin transaction (using a series of SQL commands)
# Create order
order_sql="INSERT INTO orders (user_id, total_price, shipping_address, status) 
           VALUES ($user_id, $total_price, '$shipping_address', 'pending');"

execute_sql "$order_sql"

if [ $? -ne 0 ]; then
    json_error "Failed to create order"
    exit 1
fi

# Get the new order ID
order_id=$(sqlite3 "$DB_FILE" "SELECT last_insert_rowid();")

# Process each cart item
success=true
while IFS='|' read -r product_id quantity price stock name; do
    subtotal=$(echo "$price * $quantity" | bc)
    
    # Insert order item
    item_sql="INSERT INTO order_items (order_id, product_id, product_name, quantity, price, subtotal) 
              VALUES ($order_id, $product_id, '$name', $quantity, $price, $subtotal);"
    
    execute_sql "$item_sql"
    
    if [ $? -ne 0 ]; then
        success=false
        break
    fi
    
    # Update product stock
    new_stock=$((stock - quantity))
    update_sql="UPDATE products SET stock=$new_stock WHERE id=$product_id;"
    
    execute_sql "$update_sql"
    
    if [ $? -ne 0 ]; then
        success=false
        break
    fi
done <<< "$cart_items"

if [ "$success" = false ]; then
    # Rollback: delete the order and order items
    execute_sql "DELETE FROM order_items WHERE order_id=$order_id;"
    execute_sql "DELETE FROM orders WHERE id=$order_id;"
    json_error "Failed to process order. Please try again."
    exit 1
fi

# Clear the cart
execute_sql "DELETE FROM cart WHERE user_id=$user_id;"

log_message "Order placed: Order ID $order_id, User ID $user_id, Total: \$$total_price"

echo "{\"success\": true, \"message\": \"Order placed successfully\", \"order_id\": $order_id, \"total\": $total_price}"
