#!/bin/bash
# Lab Import Script
# Import labs from packages
# Usage: ./import-lab.sh <package-file|url>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LABS_DIR="$ROOT_DIR/labs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "Lab Import Tool - Security Lab Factory"
    echo ""
    echo "Usage: $0 <package-file|url> [options]"
    echo ""
    echo "Options:"
    echo "  --name NAME     Override lab name"
    echo "  --verify        Verify checksum"
    echo "  --list          List contents without importing"
    echo "  --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 sqli-lab.lab.tar.gz"
    echo "  $0 https://example.com/labs/ctf-lab.tar.gz"
    echo "  $0 github:user/repo/lab-name"
}

# Parse arguments
SOURCE=""
LAB_NAME=""
VERIFY=false
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            LAB_NAME="$2"
            shift 2
            ;;
        --verify)
            VERIFY=true
            shift
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
        *)
            SOURCE="$1"
            shift
            ;;
    esac
done

if [ -z "$SOURCE" ]; then
    echo -e "${RED}Error: Package source required${NC}"
    show_help
    exit 1
fi

echo -e "${BLUE}Importing lab from: $SOURCE${NC}"

# Download if URL
if [[ "$SOURCE" == http* ]]; then
    echo "Downloading..."
    TEMP_FILE=$(mktemp)
    curl -L -o "$TEMP_FILE" "$SOURCE"
    SOURCE="$TEMP_FILE"
    CLEANUP_FILE=true
elif [[ "$SOURCE" == github:* ]]; then
    # GitHub format: github:user/repo/lab-name
    GITHUB_PATH="${SOURCE#github:}"
    echo "Fetching from GitHub: $GITHUB_PATH"

    # Extract parts
    IFS='/' read -r USER REPO LAB <<< "$GITHUB_PATH"

    # Download from GitHub releases or raw
    URL="https://github.com/$USER/$REPO/releases/latest/download/${LAB}.lab.tar.gz"
    TEMP_FILE=$(mktemp)
    curl -L -o "$TEMP_FILE" "$URL" || {
        echo -e "${RED}Failed to download from GitHub${NC}"
        exit 1
    }
    SOURCE="$TEMP_FILE"
    CLEANUP_FILE=true
fi

# Verify file exists
if [ ! -f "$SOURCE" ]; then
    echo -e "${RED}Error: File not found: $SOURCE${NC}"
    exit 1
fi

# List contents if requested
if [ "$LIST_ONLY" = true ]; then
    echo "Contents:"
    tar -tzf "$SOURCE"
    exit 0
fi

# Extract lab name from manifest
TEMP_DIR=$(mktemp -d)
tar -xzf "$SOURCE" -C "$TEMP_DIR"

# Read manifest
if [ -f "$TEMP_DIR/lab-manifest.yaml" ]; then
    MANIFEST_NAME=$(grep "^name:" "$TEMP_DIR/lab-manifest.yaml" | cut -d'"' -f2)
    MANIFEST_VERSION=$(grep "^version:" "$TEMP_DIR/lab-manifest.yaml" | cut -d'"' -f2)
    MANIFEST_AUTHOR=$(grep "^author:" "$TEMP_DIR/lab-manifest.yaml" | cut -d'"' -f2)
    MANIFEST_LICENSE=$(grep "^license:" "$TEMP_DIR/lab-manifest.yaml" | cut -d'"' -f2)

    echo ""
    echo "Lab Information:"
    echo "  Name:    $MANIFEST_NAME"
    echo "  Version: $MANIFEST_VERSION"
    echo "  Author:  $MANIFEST_AUTHOR"
    echo "  License: $MANIFEST_LICENSE"
    echo ""
fi

# Use manifest name if not overridden
if [ -z "$LAB_NAME" ]; then
    LAB_NAME="${MANIFEST_NAME:-imported-lab}"
fi

# Create lab directory
LAB_PATH="$LABS_DIR/$LAB_NAME"

if [ -d "$LAB_PATH" ]; then
    echo -e "${YELLOW}Warning: Lab '$LAB_NAME' already exists${NC}"
    read -p "Overwrite? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    rm -rf "$LAB_PATH"
fi

# Move to labs directory
mv "$TEMP_DIR" "$LAB_PATH"

# Cleanup
if [ "$CLEANUP_FILE" = true ] && [ -f "$TEMP_FILE" ]; then
    rm -f "$TEMP_FILE"
fi

echo -e "${GREEN}Lab imported successfully!${NC}"
echo "Location: $LAB_PATH"
echo ""
echo "Start the lab:"
echo "  cd $LAB_PATH"
echo "  docker-compose up -d"
