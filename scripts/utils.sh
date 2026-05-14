#!/bin/bash
###############################################################################
# Utility Functions for Twilight E-Commerce Platform
# Reusable functions for validation, security, and common operations
###############################################################################

# Get project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DB_FILE="$PROJECT_ROOT/database/twilight.db"
SESSION_DIR="$PROJECT_ROOT/sessions"

# Create session directory if it doesn't exist
mkdir -p "$SESSION_DIR"

###############################################################################
# Security Functions
###############################################################################

# Hash password using SHA-256
hash_password() {
    local password="$1"
    echo -n "$password" | sha256sum | awk '{print $1}'
}

# Generate random session token
generate_token() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1
}

# Sanitize input to prevent SQL injection
sanitize_input() {
    local input="$1"
    # Remove dangerous characters and escape single quotes
    echo "$input" | sed "s/'/''/g" | sed 's/[;&|`$(){}]//g'
}

# Validate email format
validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Validate username (alphanumeric, 3-20 characters)
validate_username() {
    local username="$1"
    if [[ "$username" =~ ^[a-zA-Z0-9_]{3,20}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Validate password strength (minimum 6 characters)
validate_password() {
    local password="$1"
    if [ ${#password} -ge 6 ]; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Session Management
###############################################################################

# Create session for user
create_session() {
    local user_id="$1"
    local username="$2"
    local role="$3"
    local token=$(generate_token)
    local session_file="$SESSION_DIR/${token}.session"
    
    # Create session file
    cat > "$session_file" <<EOF
USER_ID=$user_id
USERNAME=$username
ROLE=$role
CREATED=$(date +%s)
EOF
    
    chmod 600 "$session_file"
    echo "$token"
}

# Validate session token
validate_session() {
    local token="$1"
    local session_file="$SESSION_DIR/${token}.session"
    
    if [ -f "$session_file" ]; then
        # Check if session is not expired (24 hours)
        local created=$(grep "^CREATED=" "$session_file" | cut -d'=' -f2)
        local current=$(date +%s)
        local age=$((current - created))
        
        if [ $age -lt 86400 ]; then
            return 0
        else
            # Session expired, remove it
            rm -f "$session_file"
            return 1
        fi
    else
        return 1
    fi
}

# Get session data
get_session_data() {
    local token="$1"
    local session_file="$SESSION_DIR/${token}.session"
    
    if [ -f "$session_file" ]; then
        source "$session_file"
        echo "{\"user_id\": $USER_ID, \"username\": \"$USERNAME\", \"role\": \"$ROLE\"}"
    else
        echo "{\"error\": \"Invalid session\"}"
    fi
}

# Destroy session
destroy_session() {
    local token="$1"
    local session_file="$SESSION_DIR/${token}.session"
    
    if [ -f "$session_file" ]; then
        rm -f "$session_file"
        return 0
    else
        return 1
    fi
}

# Get user ID from session
get_user_id_from_session() {
    local token="$1"
    local session_file="$SESSION_DIR/${token}.session"
    
    if [ -f "$session_file" ]; then
        grep "^USER_ID=" "$session_file" | cut -d'=' -f2
    else
        echo ""
    fi
}

# Get user role from session
get_user_role_from_session() {
    local token="$1"
    local session_file="$SESSION_DIR/${token}.session"
    
    if [ -f "$session_file" ]; then
        grep "^ROLE=" "$session_file" | cut -d'=' -f2
    else
        echo ""
    fi
}

###############################################################################
# Database Helper Functions
###############################################################################

# Execute SQL query and return JSON
execute_query() {
    local query="$1"
    sqlite3 -json "$DB_FILE" "$query" 2>&1
}

# Execute SQL query and return result
execute_sql() {
    local query="$1"
    sqlite3 "$DB_FILE" "$query" 2>&1
}

# Check if user exists
user_exists() {
    local username="$1"
    local count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM users WHERE username='$(sanitize_input "$username")';")
    [ "$count" -gt 0 ]
}

# Check if email exists
email_exists() {
    local email="$1"
    local count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM users WHERE email='$(sanitize_input "$email")';")
    [ "$count" -gt 0 ]
}

# Get product by ID
get_product() {
    local product_id="$1"
    execute_query "SELECT * FROM products WHERE id=$product_id;"
}

# Check product stock
check_stock() {
    local product_id="$1"
    local quantity="$2"
    local stock=$(sqlite3 "$DB_FILE" "SELECT stock FROM products WHERE id=$product_id;")
    
    if [ -z "$stock" ]; then
        return 1
    fi
    
    if [ "$stock" -ge "$quantity" ]; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# JSON Response Functions
###############################################################################

# Create success JSON response
json_success() {
    local message="$1"
    local data="$2"
    
    if [ -n "$data" ]; then
        echo "{\"success\": true, \"message\": \"$message\", \"data\": $data}"
    else
        echo "{\"success\": true, \"message\": \"$message\"}"
    fi
}

# Create error JSON response
json_error() {
    local message="$1"
    echo "{\"success\": false, \"error\": \"$message\"}"
}

###############################################################################
# URL Encoding/Decoding
###############################################################################

# URL decode function
urldecode() {
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

# Parse POST data
parse_post_data() {
    local post_data="$1"
    local IFS='&'
    
    for param in $post_data; do
        local key="${param%%=*}"
        local value="${param#*=}"
        value=$(urldecode "$value")
        echo "${key}=${value}"
    done
}

###############################################################################
# Logging
###############################################################################

# Log message to file
log_message() {
    local message="$1"
    local log_file="$PROJECT_ROOT/twilight.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$log_file"
}
