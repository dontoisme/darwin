#!/bin/bash
#
# Darwin Firebase Integration
# Detects Firebase usage and checks emulator status
#

# Firebase detection state
FIREBASE_DETECTED=false
FIREBASE_JSON_PATH=""
FIREBASE_AUTH_PORT=""
FIREBASE_FIRESTORE_PORT=""
FIREBASE_UI_PORT=""

# Check if project uses Firebase
detect_firebase() {
    local project_dir="${1:-$PROJECT_DIR}"
    FIREBASE_DETECTED=false
    FIREBASE_JSON_PATH=""

    # Check for firebase.json
    if [ -f "$project_dir/firebase.json" ]; then
        FIREBASE_JSON_PATH="$project_dir/firebase.json"
        FIREBASE_DETECTED=true

        # Parse emulator ports
        if command -v jq &> /dev/null; then
            FIREBASE_AUTH_PORT=$(jq -r '.emulators.auth.port // empty' "$FIREBASE_JSON_PATH" 2>/dev/null)
            FIREBASE_FIRESTORE_PORT=$(jq -r '.emulators.firestore.port // empty' "$FIREBASE_JSON_PATH" 2>/dev/null)
            FIREBASE_UI_PORT=$(jq -r '.emulators.ui.port // empty' "$FIREBASE_JSON_PATH" 2>/dev/null)
        fi
        return 0
    fi

    # Check for GoogleService-Info.plist (indicates Firebase SDK usage)
    if find "$project_dir" -name "GoogleService-Info.plist" -maxdepth 3 2>/dev/null | grep -q .; then
        FIREBASE_DETECTED=true
        return 0
    fi

    return 1
}

# Check if a specific port is reachable (emulator running)
is_port_reachable() {
    local port="$1"
    local host="${2:-127.0.0.1}"

    if [ -z "$port" ]; then
        return 1
    fi

    # Try nc (netcat) first - fastest
    if command -v nc &> /dev/null; then
        nc -z -w 1 "$host" "$port" 2>/dev/null
        return $?
    fi

    # Fallback to curl
    if command -v curl &> /dev/null; then
        curl -s --connect-timeout 1 "http://$host:$port/" >/dev/null 2>&1
        return $?
    fi

    # Last resort: /dev/tcp (bash built-in)
    (echo >/dev/tcp/"$host"/"$port") 2>/dev/null
    return $?
}

# Check if Firebase emulators are running
check_firebase_emulators() {
    local auth_running=false
    local firestore_running=false

    # Use detected ports or defaults
    local auth_port="${FIREBASE_AUTH_PORT:-9099}"
    local firestore_port="${FIREBASE_FIRESTORE_PORT:-8080}"

    if is_port_reachable "$auth_port"; then
        auth_running=true
    fi

    if is_port_reachable "$firestore_port"; then
        firestore_running=true
    fi

    # Export status
    FIREBASE_AUTH_RUNNING=$auth_running
    FIREBASE_FIRESTORE_RUNNING=$firestore_running
    export FIREBASE_AUTH_RUNNING FIREBASE_FIRESTORE_RUNNING

    # Return success if both are running
    if [ "$auth_running" = true ] && [ "$firestore_running" = true ]; then
        return 0
    fi
    return 1
}

# Get screens that require Firebase from manifest
get_firebase_screens() {
    local manifest_path="$1"

    if [ ! -f "$manifest_path" ]; then
        return 1
    fi

    # Get screen IDs where requires_firebase is true
    jq -r '.screens | to_entries[] | select(.value.requires_firebase == true) | .key' "$manifest_path" 2>/dev/null
}

# Get count of screens requiring Firebase
count_firebase_screens() {
    local manifest_path="$1"

    if [ ! -f "$manifest_path" ]; then
        echo "0"
        return
    fi

    jq '[.screens | to_entries[] | select(.value.requires_firebase == true)] | length' "$manifest_path" 2>/dev/null || echo "0"
}

# Print Firebase status
print_firebase_status() {
    if [ "$FIREBASE_DETECTED" = true ]; then
        echo -e "${BLUE}Firebase:${NC} Detected"
        if [ -n "$FIREBASE_JSON_PATH" ]; then
            echo "  Config: $FIREBASE_JSON_PATH"
        fi

        # Check emulators
        local auth_port="${FIREBASE_AUTH_PORT:-9099}"
        local firestore_port="${FIREBASE_FIRESTORE_PORT:-8080}"

        echo "  Emulators:"
        if is_port_reachable "$auth_port"; then
            echo -e "    ${GREEN}✓${NC} Auth (port $auth_port)"
        else
            echo -e "    ${RED}✗${NC} Auth (port $auth_port)"
        fi

        if is_port_reachable "$firestore_port"; then
            echo -e "    ${GREEN}✓${NC} Firestore (port $firestore_port)"
        else
            echo -e "    ${RED}✗${NC} Firestore (port $firestore_port)"
        fi
    else
        echo -e "${BLUE}Firebase:${NC} Not detected"
    fi
}

# Get command to start emulators
get_emulator_start_command() {
    if [ -n "$FIREBASE_JSON_PATH" ]; then
        local project_dir=$(dirname "$FIREBASE_JSON_PATH")
        echo "cd \"$project_dir\" && firebase emulators:start --only auth,firestore"
    else
        echo "firebase emulators:start --only auth,firestore"
    fi
}

# Export functions
export -f detect_firebase
export -f is_port_reachable
export -f check_firebase_emulators
export -f get_firebase_screens
export -f count_firebase_screens
export -f print_firebase_status
export -f get_emulator_start_command
