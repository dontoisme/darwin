#!/bin/bash
#
# Darwin configuration loader
# Reads darwin.json and exports configuration variables
#

# Default config file name
CONFIG_FILE="darwin.json"

# Configuration variables (set to defaults)
CONFIG_PROJECT=""
CONFIG_SCHEME=""
CONFIG_TEST_TARGET="UITests"
CONFIG_TEST_CLASS="ScreenshotTests"
CONFIG_DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro"
CONFIG_OUTPUT_DIR="Screenshots"
CONFIG_MANIFEST="Screenshots/manifest.json"
CONFIG_RESULTS_DIR="TestResults"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Find config file by walking up directory tree
find_config() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/$CONFIG_FILE" ]; then
            echo "$dir/$CONFIG_FILE"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Load configuration from darwin.json
load_config() {
    local config_path="${1:-}"

    # If no path given, find it
    if [ -z "$config_path" ]; then
        config_path=$(find_config "$(pwd)")
    fi

    if [ -z "$config_path" ] || [ ! -f "$config_path" ]; then
        return 1
    fi

    # Set PROJECT_DIR to the directory containing darwin.json
    PROJECT_DIR="$(dirname "$config_path")"
    export PROJECT_DIR

    # Parse JSON and export variables
    if command -v jq &> /dev/null; then
        CONFIG_PROJECT=$(jq -r '.project // empty' "$config_path")
        CONFIG_SCHEME=$(jq -r '.scheme // empty' "$config_path")
        CONFIG_TEST_TARGET=$(jq -r '.testTarget // "UITests"' "$config_path")
        CONFIG_TEST_CLASS=$(jq -r '.testClass // "ScreenshotTests"' "$config_path")
        CONFIG_DESTINATION=$(jq -r '.destination // "platform=iOS Simulator,name=iPhone 16 Pro"' "$config_path")
        CONFIG_OUTPUT_DIR=$(jq -r '.outputDir // "Screenshots"' "$config_path")
        CONFIG_MANIFEST=$(jq -r '.manifest // "Screenshots/manifest.json"' "$config_path")
        CONFIG_RESULTS_DIR=$(jq -r '.resultsDir // "TestResults"' "$config_path")
    else
        echo -e "${RED}Error: jq is required but not installed.${NC}"
        echo "Install with: brew install jq"
        return 1
    fi

    # Build full paths
    if [ -n "$CONFIG_PROJECT" ]; then
        CONFIG_PROJECT_PATH="$PROJECT_DIR/$CONFIG_PROJECT"
    fi
    CONFIG_OUTPUT_PATH="$PROJECT_DIR/$CONFIG_OUTPUT_DIR"
    CONFIG_MANIFEST_PATH="$PROJECT_DIR/$CONFIG_MANIFEST"
    CONFIG_RESULTS_PATH="$PROJECT_DIR/$CONFIG_RESULTS_DIR"

    export CONFIG_PROJECT CONFIG_SCHEME CONFIG_TEST_TARGET CONFIG_TEST_CLASS
    export CONFIG_DESTINATION CONFIG_OUTPUT_DIR CONFIG_MANIFEST
    export CONFIG_PROJECT_PATH CONFIG_OUTPUT_PATH CONFIG_MANIFEST_PATH CONFIG_RESULTS_PATH

    return 0
}

# Auto-detect project settings if no config found
auto_detect_project() {
    local dir="${1:-.}"

    # Find .xcodeproj
    local xcodeproj=$(ls -d "$dir"/*.xcodeproj 2>/dev/null | head -1)
    if [ -n "$xcodeproj" ]; then
        CONFIG_PROJECT=$(basename "$xcodeproj")
        CONFIG_PROJECT_PATH="$xcodeproj"

        # Try to detect scheme (use project name without .xcodeproj)
        CONFIG_SCHEME=$(basename "$xcodeproj" .xcodeproj)

        echo -e "${GREEN}Auto-detected:${NC}"
        echo "  Project: $CONFIG_PROJECT"
        echo "  Scheme: $CONFIG_SCHEME"
        return 0
    fi

    # Find .xcworkspace
    local xcworkspace=$(ls -d "$dir"/*.xcworkspace 2>/dev/null | head -1)
    if [ -n "$xcworkspace" ]; then
        CONFIG_PROJECT=$(basename "$xcworkspace")
        CONFIG_PROJECT_PATH="$xcworkspace"
        CONFIG_SCHEME=$(basename "$xcworkspace" .xcworkspace)

        echo -e "${GREEN}Auto-detected workspace:${NC}"
        echo "  Workspace: $CONFIG_PROJECT"
        echo "  Scheme: $CONFIG_SCHEME"
        return 0
    fi

    return 1
}

# Print current configuration
print_config() {
    echo "Darwin Configuration:"
    echo "  Project:      ${CONFIG_PROJECT:-<not set>}"
    echo "  Scheme:       ${CONFIG_SCHEME:-<not set>}"
    echo "  Test Target:  ${CONFIG_TEST_TARGET}"
    echo "  Test Class:   ${CONFIG_TEST_CLASS}"
    echo "  Destination:  ${CONFIG_DESTINATION}"
    echo "  Output Dir:   ${CONFIG_OUTPUT_DIR}"
    echo "  Manifest:     ${CONFIG_MANIFEST}"
}

# Validate required configuration
validate_config() {
    local errors=0

    if [ -z "$CONFIG_PROJECT" ]; then
        echo -e "${RED}Error: No project specified${NC}"
        errors=$((errors + 1))
    elif [ ! -e "$CONFIG_PROJECT_PATH" ]; then
        echo -e "${RED}Error: Project not found: $CONFIG_PROJECT_PATH${NC}"
        errors=$((errors + 1))
    fi

    if [ -z "$CONFIG_SCHEME" ]; then
        echo -e "${RED}Error: No scheme specified${NC}"
        errors=$((errors + 1))
    fi

    return $errors
}
