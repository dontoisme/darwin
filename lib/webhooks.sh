#!/bin/bash
#
# Darwin webhook notifications
# Sends notifications to Slack on capture success/failure
#

# Send Slack notification
# Usage: send_slack_notification "success|failure" "Captured 5 screens"
#
# Requires these variables to be set:
#   PROJECT_DIR - path to project root (set by config.sh)
#   GIT_COMMIT, GIT_BRANCH, MODE, SCREENSHOT_COUNT - capture details
#
send_slack_notification() {
    local status="$1"
    local message="$2"

    # Find config file to get webhook URL
    local config_file="$PROJECT_DIR/darwin.json"
    if [ ! -f "$config_file" ]; then
        return 0  # No config, skip silently
    fi

    # Get webhook URL from config
    local webhook_url=$(jq -r '.slack_webhook // empty' "$config_file" 2>/dev/null)
    if [ -z "$webhook_url" ]; then
        return 0  # No webhook configured, skip silently
    fi

    # Build viewer path
    local viewer_path="file://$PROJECT_DIR/$CONFIG_OUTPUT_DIR/viewer.html"

    # Choose emoji based on status
    local emoji="✅"
    local title="Darwin Capture Complete"
    if [ "$status" == "failure" ]; then
        emoji="❌"
        title="Darwin Capture Failed"
    fi

    # Build Slack message (simple text format for reliability)
    local text="$emoji *$title*
Commit: \`${GIT_COMMIT:-unknown}\` (${GIT_BRANCH:-unknown})
Mode: ${MODE:-unknown}
Screens: ${SCREENSHOT_COUNT:-0} captured
📂 Viewer: \`$viewer_path\`"

    # Build JSON payload with jq to handle escaping
    local payload=$(jq -n --arg text "$text" '{text: $text}')

    # Send to Slack (silently, don't fail capture on webhook error)
    curl -s -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1 || true
}
