#!/bin/bash
# Reads Secrets.xcconfig (or env vars) and generates CleanupSimulators/Secrets.swift
# Usage: ./generate-secrets.sh
# CI:    TBC_API_KEY=xxx TBC_API_SECRET=yyy ./generate-secrets.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/Secrets.xcconfig"
OUTPUT="$SCRIPT_DIR/CleanupSimulators/Secrets.swift"

read_config() {
    local key="$1"
    # Env var takes priority over xcconfig
    local val="${!key}"
    if [ -z "$val" ] && [ -f "$CONFIG" ]; then
        val=$(grep "^$key" "$CONFIG" | head -1 | cut -d'=' -f2- | xargs)
    fi
    echo "$val"
}

APP_ID=$(read_config TBC_APP_ID)
API_KEY=$(read_config TBC_API_KEY)
API_SECRET=$(read_config TBC_API_SECRET)

cat > "$OUTPUT" << EOF
// Auto-generated from Secrets.xcconfig — do not edit manually.
enum Secrets {
    static let tbcAppId = "$APP_ID"
    static let tbcApiKey = "$API_KEY"
    static let tbcApiSecret = "$API_SECRET"
}
EOF

echo "Generated $OUTPUT"
