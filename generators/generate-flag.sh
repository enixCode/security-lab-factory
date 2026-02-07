#!/bin/bash
# Flag Generator
# Generates CTF-style flags
# Usage: ./generate-flag.sh <category> <description>

generate_flag() {
    local category="${1:-generic}"
    local description="${2:-challenge}"

    # Generate random suffix
    local random_suffix=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 6 | head -n 1 2>/dev/null || echo "$(date +%s)" | md5sum | cut -c1-6)

    # Clean description
    local clean_desc=$(echo "$description" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_' | cut -c1-30)

    # Generate flag
    echo "FLAG{${category}_${clean_desc}_${random_suffix}}"
}

# If called with arguments, generate a single flag
if [ -n "$1" ]; then
    generate_flag "$1" "$2"
    exit 0
fi

# Interactive mode
echo "Flag Generator - Security Lab Factory"
echo "======================================"
echo ""
echo "Categories:"
echo "  web, network, cloud, crypto, pwn, forensics, reversing, misc"
echo ""

read -p "Category: " category
read -p "Description: " description

echo ""
echo "Generated flag:"
generate_flag "$category" "$description"
