#!/bin/bash
###############################################################################
# Orders Script for Twilight E-Commerce Platform
# View and manage orders
###############################################################################

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Set content type for CGI
echo "Content-Type: application/json"
echo ""

# Parse query parameters
token=""
order_id=""
action="view"

if [ -n "$QUERY_STRING" ]; then
    IFS='&'
    for param in $QUERY_STRING; do
        key="${param%%=*}"
        value="${param#*=}"
        value=$(urldecode "$value")
        
        case "$key" in
            token) token="$value" ;;
            id) order_id="$value" ;;
            action) action="$value" ;;
        esac
    done
fi

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
role=$(get_user_role_from_session "$token")

case "$action" in
    view)
        if [ -n "$order_id" ]; then
            # Get specific order with items
            if [ "$role" = "admin" ]; then
                # Admin can view any order
                order_query="SELECT * FROM orders WHERE id=$order_id;"
            else
                # Customer can only view their own orders
                order_query="SELECT * FROM orders WHERE id=$order_id AND user_id=$user_id;"
            fi
            
            order=$(execute_query "$order_query")
            
            if [ -z "$order" ] || [ "$order" = "[]" ]; then
                json_error "Order not found"
                exit 1
            fi
            
            # Get order items
            items_query="SELECT * FROM order_items WHERE order_id=$order_id;"
            items=$(execute_query "$items_query")
            
            echo "{\"success\": true, \"order\": $order, \"items\": $items}"
        else
            # Get all orders
            if [ "$role" = "admin" ]; then
                # Admin sees all orders with user info
                query="SELECT o.*, u.username, u.email FROM orders o 
                       JOIN users u ON o.user_id = u.id 
                       ORDER BY o.created_at DESC;"
            else
                # Customer sees only their orders
                query="SELECT * FROM orders WHERE user_id=$user_id ORDER BY created_at DESC;"
            fi
            
            orders=$(execute_query "$query")
            
            if [ -z "$orders" ] || [ "$orders" = "[]" ]; then
                echo "{\"success\": true, \"orders\": [], \"message\": \"No orders found\"}"
            else
                echo "{\"success\": true, \"orders\": $orders}"
            fi
        fi
        ;;
        
    *)
        json_error "Invalid action"
        exit 1
        ;;
esac
