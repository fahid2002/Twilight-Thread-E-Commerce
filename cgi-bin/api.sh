#!/bin/bash
###############################################################################
# Main CGI API Handler for Twilight E-Commerce Platform
# Routes requests to appropriate backend scripts
###############################################################################

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && cd scripts && pwd)"

# Parse query string to get action
action=""
if [ -n "$QUERY_STRING" ]; then
    # Extract action parameter
    action=$(echo "$QUERY_STRING" | grep -oP 'action=\K[^&]+')
fi

# Route to appropriate script based on action
case "$action" in
    register)
        bash "$SCRIPT_DIR/register.sh"
        ;;
    login)
        bash "$SCRIPT_DIR/login.sh"
        ;;
    logout)
        bash "$SCRIPT_DIR/logout.sh"
        ;;
    show_products)
        bash "$SCRIPT_DIR/show_products.sh"
        ;;
    add_product)
        bash "$SCRIPT_DIR/add_product.sh"
        ;;
    update_product)
        bash "$SCRIPT_DIR/update_product.sh"
        ;;
    delete_product)
        bash "$SCRIPT_DIR/delete_product.sh"
        ;;
    cart_handler)
        bash "$SCRIPT_DIR/cart_handler.sh"
        ;;
    checkout)
        bash "$SCRIPT_DIR/checkout.sh"
        ;;
    orders)
        bash "$SCRIPT_DIR/orders.sh"
        ;;
    place_order)
        bash "$SCRIPT_DIR/place_order.sh"
        ;;
    get_users)
        bash "$SCRIPT_DIR/get_users.sh"
        ;;
    *)
        echo "Content-Type: application/json"
        echo ""
        echo "{\"success\": false, \"error\": \"Invalid action or action not specified\"}"
        ;;
esac
