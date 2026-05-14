#!/bin/bash
###############################################################################
# Show Products Script for Twilight E-Commerce Platform
# Returns product listing with optional filtering
###############################################################################

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Set content type for CGI
echo "Content-Type: application/json"
echo ""

# Parse query parameters
category=""
search=""
product_id=""
limit=""

if [ -n "$QUERY_STRING" ]; then
    IFS='&'
    for param in $QUERY_STRING; do
        key="${param%%=*}"
        value="${param#*=}"
        value=$(urldecode "$value")
        
        case "$key" in
            category) category="$value" ;;
            search) search="$value" ;;
            id) product_id="$value" ;;
            limit) limit="$value" ;;
        esac
    done
fi

# Build SQL query
if [ -n "$product_id" ]; then
    # Get single product by ID
    query="SELECT * FROM products WHERE id=$product_id;"
else
    # Get all products with optional filters
    query="SELECT * FROM products WHERE 1=1"
    
    if [ -n "$category" ]; then
        category=$(sanitize_input "$category")
        query="$query AND category='$category'"
    fi
    
    if [ -n "$search" ]; then
        search=$(sanitize_input "$search")
        query="$query AND (name LIKE '%$search%' OR description LIKE '%$search%')"
    fi
    
    query="$query ORDER BY created_at DESC"
    
    if [ -n "$limit" ]; then
        query="$query LIMIT $limit"
    fi
    
    query="$query;"
fi

# Execute query and return JSON
result=$(execute_query "$query")

# Check if result is empty or error
if [ -z "$result" ] || [[ "$result" == *"Error"* ]]; then
    echo "{\"success\": false, \"products\": [], \"message\": \"No products found\"}"
else
    echo "{\"success\": true, \"products\": $result}"
fi
