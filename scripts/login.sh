#!/bin/bash
###############################################################################
# User Login Script for Twilight E-Commerce Platform
# Authenticates users and creates sessions
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
    # For command line testing
    POST_DATA="$1"
fi

# Parse input parameters
username=""
password=""

IFS='&'
for param in $POST_DATA; do
    key="${param%%=*}"
    value="${param#*=}"
    value=$(urldecode "$value")
    
    case "$key" in
        username) username="$value" ;;
        password) password="$value" ;;
    esac
done

# Validate required fields
if [ -z "$username" ] || [ -z "$password" ]; then
    json_error "Username and password are required"
    exit 1
fi

# Sanitize username
username=$(sanitize_input "$username")

# Hash the password
password_hash=$(hash_password "$password")

# Query user from database
user_data=$(sqlite3 "$DB_FILE" "SELECT id, username, role, email, full_name FROM users WHERE username='$username' AND password='$password_hash';")

if [ -z "$user_data" ]; then
    json_error "Invalid username or password"
    log_message "Failed login attempt for username: $username"
    exit 1
fi

# Parse user data
IFS='|' read -r user_id username role email full_name <<< "$user_data"

# Create session
token=$(create_session "$user_id" "$username" "$role")

log_message "User logged in: $username (ID: $user_id, Role: $role)"

# Return success with session token
echo "{\"success\": true, \"message\": \"Login successful\", \"token\": \"$token\", \"user\": {\"id\": $user_id, \"username\": \"$username\", \"role\": \"$role\", \"email\": \"$email\", \"full_name\": \"$full_name\"}}"
