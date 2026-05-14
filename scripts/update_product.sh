#!/bin/bash
###############################################################################
# Update Product Script for Twilight E-Commerce Platform
# Admin only - updates existing products
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
name=""
description=""
price=""
stock=""
category=""
image=""

IFS='&'
for param in $POST_DATA; do
    key="${param%%=*}"
    value="${param#*=}"
    value=$(urldecode "$value")
    
    case "$key" in
        token) token="$value" ;;
        id) product_id="$value" ;;
        name) name="$value" ;;
        description) description="$value" ;;
        price) price="$value" ;;
        stock) stock="$value" ;;
        category) category="$value" ;;
        image) image="$value" ;;
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

# Build UPDATE query dynamically based on provided fields
updates=""

if [ -n "$name" ]; then
    name=$(sanitize_input "$name")
    updates="${updates}name='$name', "
fi

if [ -n "$description" ]; then
    description=$(sanitize_input "$description")
    updates="${updates}description='$description', "
fi

if [ -n "$price" ]; then
    if [[ "$price" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        updates="${updates}price=$price, "
    fi
fi

if [ -n "$stock" ]; then
    if [[ "$stock" =~ ^[0-9]+$ ]]; then
        updates="${updates}stock=$stock, "
    fi
fi

if [ -n "$category" ]; then
    category=$(sanitize_input "$category")
    updates="${updates}category='$category', "
fi

if [ -n "$image" ]; then
    image=$(sanitize_input "$image")
    updates="${updates}image='$image', "
fi

# Add updated_at timestamp
updates="${updates}updated_at=CURRENT_TIMESTAMP"

# Remove trailing comma if exists
updates=$(echo "$updates" | sed 's/, $//')

if [ -z "$updates" ]; then
    json_error "No fields to update"
    exit 1
fi

# Execute update
sql="UPDATE products SET $updates WHERE id=$product_id;"
result=$(execute_sql "$sql")

if [ $? -eq 0 ]; then
    log_message "Product updated by admin: ID $product_id"
    echo "{\"success\": true, \"message\": \"Product updated successfully\"}"
else
    json_error "Failed to update product: $result"
    exit 1
fi
