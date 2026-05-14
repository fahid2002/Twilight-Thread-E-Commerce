#!/bin/bash
###############################################################################
# Cart Handler Script for Twilight E-Commerce Platform
# Manages shopping cart operations: add, remove, update, view
###############################################################################

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Set content type for CGI
echo "Content-Type: application/json"
echo ""

# Read POST data or query string
if [ "$REQUEST_METHOD" = "POST" ]; then
    read -r POST_DATA
    DATA="$POST_DATA"
elif [ "$REQUEST_METHOD" = "GET" ]; then
    DATA="$QUERY_STRING"
else
    DATA="$1"
fi

# Parse input parameters
token=""
action=""
product_id=""
quantity=""

IFS='&'
for param in $DATA; do
    key="${param%%=*}"
    value="${param#*=}"
    value=$(urldecode "$value")
    
    case "$key" in
        token) token="$value" ;;
        action) action="$value" ;;
        product_id) product_id="$value" ;;
        quantity) quantity="$value" ;;
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

# Handle different cart actions
case "$action" in
    add)
        # Add item to cart
        if [ -z "$product_id" ] || [ -z "$quantity" ]; then
            json_error "Product ID and quantity are required"
            exit 1
        fi
        
        # Validate quantity
        if ! [[ "$quantity" =~ ^[0-9]+$ ]] || [ "$quantity" -lt 1 ]; then
            json_error "Quantity must be a positive number"
            exit 1
        fi
        
        # Check if product exists and has enough stock
        product_stock=$(sqlite3 "$DB_FILE" "SELECT stock FROM products WHERE id=$product_id;")
        
        if [ -z "$product_stock" ]; then
            json_error "Product not found"
            exit 1
        fi
        
        if [ "$product_stock" -lt "$quantity" ]; then
            json_error "Insufficient stock. Available: $product_stock"
            exit 1
        fi
        
        # Check if item already in cart
        existing_qty=$(sqlite3 "$DB_FILE" "SELECT quantity FROM cart WHERE user_id=$user_id AND product_id=$product_id;")
        
        if [ -n "$existing_qty" ]; then
            # Update quantity
            new_qty=$((existing_qty + quantity))
            
            if [ "$product_stock" -lt "$new_qty" ]; then
                json_error "Insufficient stock. Available: $product_stock, In cart: $existing_qty"
                exit 1
            fi
            
            sql="UPDATE cart SET quantity=$new_qty WHERE user_id=$user_id AND product_id=$product_id;"
        else
            # Insert new item
            sql="INSERT INTO cart (user_id, product_id, quantity) VALUES ($user_id, $product_id, $quantity);"
        fi
        
        execute_sql "$sql"
        
        if [ $? -eq 0 ]; then
            log_message "User $user_id added product $product_id to cart (qty: $quantity)"
            echo "{\"success\": true, \"message\": \"Item added to cart\"}"
        else
            json_error "Failed to add item to cart"
            exit 1
        fi
        ;;
        
    remove)
        # Remove item from cart
        if [ -z "$product_id" ]; then
            json_error "Product ID is required"
            exit 1
        fi
        
        sql="DELETE FROM cart WHERE user_id=$user_id AND product_id=$product_id;"
        execute_sql "$sql"
        
        if [ $? -eq 0 ]; then
            log_message "User $user_id removed product $product_id from cart"
            echo "{\"success\": true, \"message\": \"Item removed from cart\"}"
        else
            json_error "Failed to remove item from cart"
            exit 1
        fi
        ;;
        
    update)
        # Update item quantity
        if [ -z "$product_id" ] || [ -z "$quantity" ]; then
            json_error "Product ID and quantity are required"
            exit 1
        fi
        
        # Validate quantity
        if ! [[ "$quantity" =~ ^[0-9]+$ ]]; then
            json_error "Quantity must be a positive number"
            exit 1
        fi
        
        # If quantity is 0, remove item
        if [ "$quantity" -eq 0 ]; then
            sql="DELETE FROM cart WHERE user_id=$user_id AND product_id=$product_id;"
        else
            # Check stock
            product_stock=$(sqlite3 "$DB_FILE" "SELECT stock FROM products WHERE id=$product_id;")
            
            if [ "$product_stock" -lt "$quantity" ]; then
                json_error "Insufficient stock. Available: $product_stock"
                exit 1
            fi
            
            sql="UPDATE cart SET quantity=$quantity WHERE user_id=$user_id AND product_id=$product_id;"
        fi
        
        execute_sql "$sql"
        
        if [ $? -eq 0 ]; then
            log_message "User $user_id updated cart item $product_id (qty: $quantity)"
            echo "{\"success\": true, \"message\": \"Cart updated\"}"
        else
            json_error "Failed to update cart"
            exit 1
        fi
        ;;
        
    view)
        # Get cart items with product details
        query="SELECT c.id, c.product_id, p.name, p.description, p.price, c.quantity, 
               (p.price * c.quantity) as subtotal, p.image, p.stock
               FROM cart c
               JOIN products p ON c.product_id = p.id
               WHERE c.user_id=$user_id
               ORDER BY c.added_at DESC;"
        
        result=$(execute_query "$query")
        
        if [ -z "$result" ] || [ "$result" = "[]" ]; then
            echo "{\"success\": true, \"cart\": [], \"total\": 0, \"count\": 0}"
        else
            # Calculate total
            total=$(sqlite3 "$DB_FILE" "SELECT COALESCE(SUM(p.price * c.quantity), 0) FROM cart c JOIN products p ON c.product_id = p.id WHERE c.user_id=$user_id;")
            count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM cart WHERE user_id=$user_id;")
            
            echo "{\"success\": true, \"cart\": $result, \"total\": $total, \"count\": $count}"
        fi
        ;;
        
    clear)
        # Clear entire cart
        sql="DELETE FROM cart WHERE user_id=$user_id;"
        execute_sql "$sql"
        
        if [ $? -eq 0 ]; then
            log_message "User $user_id cleared cart"
            echo "{\"success\": true, \"message\": \"Cart cleared\"}"
        else
            json_error "Failed to clear cart"
            exit 1
        fi
        ;;
        
    count)
        # Get cart item count
        count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM cart WHERE user_id=$user_id;")
        echo "{\"success\": true, \"count\": $count}"
        ;;
        
    *)
        json_error "Invalid action. Use: add, remove, update, view, clear, or count"
        exit 1
        ;;
esac
