#!/bin/bash
###############################################################################
# Logout Script for Twilight E-Commerce Platform
# Destroys user session
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
    token=$(echo "$POST_DATA" | grep -oP 'token=\K[^&]+')
else
    token=$(echo "$QUERY_STRING" | grep -oP 'token=\K[^&]+')
fi

# Decode token
token=$(urldecode "$token")

# Validate and destroy session
if [ -n "$token" ]; then
    if destroy_session "$token"; then
        log_message "User logged out with token: ${token:0:10}..."
        json_success "Logout successful"
    else
        json_error "Invalid session"
    fi
else
    json_error "Token is required"
fi
