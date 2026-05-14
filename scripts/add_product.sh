#!/bin/bash
###############################################################################
# Add Product Script for Twilight E-Commerce Platform
# Admin only - adds new products to the database
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

# Validate required fields
if [ -z "$name" ] || [ -z "$price" ] || [ -z "$stock" ]; then
    json_error "Name, price, and stock are required"
    exit 1
fi

# Validate price and stock are numbers
if ! [[ "$price" =~ ^[0-9]+\.?[0-9]*$ ]] || ! [[ "$stock" =~ ^[0-9]+$ ]]; then
    json_error "Price and stock must be valid numbers"
    exit 1
fi

# Sanitize inputs
name=$(sanitize_input "$name")
description=$(sanitize_input "$description")
category=$(sanitize_input "$category")
image=$(sanitize_input "$image")

# Set default image if not provided
if [ -z "$image" ]; then
    image="placeholder.jpg"
fi

# Insert product into database
sql="INSERT INTO products (name, description, price, stock, category, image) 
     VALUES ('$name', '$description', $price, $stock, '$category', '$image');"

result=$(execute_sql "$sql")

if [ $? -eq 0 ]; then
    # Get the new product ID
    product_id=$(sqlite3 "$DB_FILE" "SELECT last_insert_rowid();")
    
    log_message "Product added by admin: $name (ID: $product_id)"
    
    echo "{\"success\": true, \"message\": \"Product added successfully\", \"product_id\": $product_id}"
else
    json_error "Failed to add product: $result"
    exit 1
fi
