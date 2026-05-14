#!/bin/bash
###############################################################################
# User Registration Script for Twilight E-Commerce Platform
# Handles registration for both admin and customer users
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
email=""
role="customer"
full_name=""
phone=""
address=""

IFS='&'
for param in $POST_DATA; do
    key="${param%%=*}"
    value="${param#*=}"
    value=$(urldecode "$value")
    
    case "$key" in
        username) username="$value" ;;
        password) password="$value" ;;
        email) email="$value" ;;
        role) role="$value" ;;
        full_name) full_name="$value" ;;
        phone) phone="$value" ;;
        address) address="$value" ;;
    esac
done

# Validate required fields
if [ -z "$username" ] || [ -z "$password" ] || [ -z "$email" ]; then
    json_error "Username, password, and email are required"
    exit 1
fi

# Validate username format
if ! validate_username "$username"; then
    json_error "Username must be 3-20 characters and contain only letters, numbers, and underscores"
    exit 1
fi

# Validate password strength
if ! validate_password "$password"; then
    json_error "Password must be at least 6 characters long"
    exit 1
fi

# Validate email format
if ! validate_email "$email"; then
    json_error "Invalid email format"
    exit 1
fi

# Validate role
if [ "$role" != "admin" ] && [ "$role" != "customer" ]; then
    role="customer"
fi

# Sanitize inputs
username=$(sanitize_input "$username")
email=$(sanitize_input "$email")
full_name=$(sanitize_input "$full_name")
phone=$(sanitize_input "$phone")
address=$(sanitize_input "$address")

# Check if username already exists
if user_exists "$username"; then
    json_error "Username already exists"
    exit 1
fi

# Check if email already exists
if email_exists "$email"; then
    json_error "Email already exists"
    exit 1
fi

# Hash the password
password_hash=$(hash_password "$password")

# Insert user into database
sql="INSERT INTO users (username, password, email, role, full_name, phone, address) 
     VALUES ('$username', '$password_hash', '$email', '$role', '$full_name', '$phone', '$address');"

result=$(execute_sql "$sql")

if [ $? -eq 0 ]; then
    # Get the new user ID
    user_id=$(sqlite3 "$DB_FILE" "SELECT id FROM users WHERE username='$username';")
    
    # Create session for the new user
    token=$(create_session "$user_id" "$username" "$role")
    
    log_message "New user registered: $username (ID: $user_id, Role: $role)"
    
    echo "{\"success\": true, \"message\": \"Registration successful\", \"token\": \"$token\", \"user\": {\"id\": $user_id, \"username\": \"$username\", \"role\": \"$role\"}}"
else
    json_error "Registration failed: $result"
    exit 1
fi
