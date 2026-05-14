#!/bin/bash
###############################################################################
# Get All Users Script for Twilight E-Commerce Platform
# Returns list of all users (admin only)
###############################################################################

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Set content type for CGI
echo "Content-Type: application/json"
echo ""

# Get session token from cookie or query string
token=$(get_token_from_request)

# Validate admin session
if [ -z "$token" ] || ! validate_session "$token"; then
    error_response "Unauthorized: Please login"
    exit 1
fi

# Check if user is admin
role=$(get_user_role "$token")
if [ "$role" != "admin" ]; then
    error_response "Forbidden: Admin access required"
    exit 1
fi

# Get all users from database
users=$(sqlite3 -json "$DB_FILE" "
    SELECT id, username, email, full_name, phone, address, role, created_at 
    FROM users 
    ORDER BY created_at DESC
")

# Return success response
echo "{\"success\": true, \"users\": $users}"
exit 0
