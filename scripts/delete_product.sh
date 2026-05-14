#!/bin/bash
###############################################################################
# Delete Product Script for Twilight E-Commerce Platform
# Admin only - removes products from database
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
product_id=""

IFS='&'
for param in $POST_DATA; do
    key="${param%%=*}"
    value="${param#*=}"
    value=$(urldecode "$value")
    
    case "$key" in
        token) token="$value" ;;
        id) product_id="$value" ;;
    esac
done

# Validate session and check admin role
if [ -z "$token" ]; then
    json_error "Authentication required"
    exit 1
fi

if ! validate_session "$token"; then
    json_error "Invalid or expired session"
    exit 1
fi

role=$(get_user_role_from_session "$token")
if [ "$role" != "admin" ]; then
    json_error "Admin access required"
    exit 1
fi

# Validate product ID
if [ -z "$product_id" ]; then
    json_error "Product ID is required"
    exit 1
fi

# Check if product exists
existing=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM products WHERE id=$product_id;")
if [ "$existing" -eq 0 ]; then
    json_error "Product not found"
    exit 1
fi

# Delete product
sql="DELETE FROM products WHERE id=$product_id;"
result=$(execute_sql "$sql")

if [ $? -eq 0 ]; then
    log_message "Product deleted by admin: ID $product_id"
    echo "{\"success\": true, \"message\": \"Product deleted successfully\"}"
else
    json_error "Failed to delete product: $result"
    exit 1
fi
