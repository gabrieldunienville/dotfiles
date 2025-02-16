#!/bin/bash

# Check for required tools
if ! command -v wl-paste &> /dev/null; then
    echo "Error: wl-clipboard is not installed. Please install it with: sudo apt-get install wl-clipboard"
    exit 1
fi

if ! command -v wtype &> /dev/null; then
    echo "Error: wtype is not installed. Please install it with: sudo apt-get install wtype"
    exit 1
fi

# Get the current clipboard content
clipboard_content=$(wl-paste)

if [ -z "$clipboard_content" ]; then
    echo "Error: Clipboard is empty"
    exit 1
fi

# Wrap the content in triple backticks
wrapped_content="$(printf "\`\`\`\n%s\n\`\`\`" "$clipboard_content")"

# Type out the wrapped content
echo -n "$wrapped_content" | wtype -
