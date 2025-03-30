#!/bin/bash

# Check if wl-clipboard is installed
if ! command -v wl-paste &> /dev/null; then
    echo "Error: wl-clipboard is not installed. Please install it with: sudo apt-get install wl-clipboard"
    exit 1
fi

# Get the current clipboard content
clipboard_content=$(wl-paste)

if [ -z "$clipboard_content" ]; then
    echo "Error: Clipboard is empty"
    exit 1
fi

# Save original content for later
original_content="$clipboard_content"

# Function to find the minimum indentation level
get_min_indent() {
    local min_spaces=999
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines
        if [[ -z "${line// }" ]]; then
            continue
        fi
        # Count leading spaces
        local spaces=$(echo "$line" | awk '{ match($0, /^[ \t]*/); print RLENGTH }')
        if [ "$spaces" -lt "$min_spaces" ]; then
            min_spaces=$spaces
        fi
    done <<< "$1"
    echo "$min_spaces"
}

# Remove the minimum level of indentation from all lines
normalize_indent() {
    local min_indent=$(get_min_indent "$1")
    if [ "$min_indent" -eq 999 ] || [ "$min_indent" -eq 0 ]; then
        echo "$1"
    else
        echo "$1" | sed "s/^[ \t]{$min_indent}//" | sed "s/^[ \t]\{$min_indent\}//"
    fi
}

# Normalize indentation and wrap in triple backticks
normalized_content=$(normalize_indent "$clipboard_content")
wrapped_content="$(printf "\`\`\`\n%s\n\`\`\`\n" "$normalized_content")"

# Put wrapped content in clipboard
echo -n "$wrapped_content" | wl-copy

# Simulate Ctrl+V using wtype
wtype -M ctrl -M shift v -m shift -m ctrl

# Small delay to ensure paste completes
sleep 0.1

# Restore original clipboard content
echo -n "$original_content" | wl-copy
