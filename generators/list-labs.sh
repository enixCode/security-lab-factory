#!/bin/bash
# List all available labs
# Usage: ./list-labs.sh [--running]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LABS_DIR="$ROOT_DIR/labs"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SHOW_RUNNING="${1:-}"

echo "========================================"
echo "   Security Lab Factory - Labs"
echo "========================================"
echo ""

if [ ! -d "$LABS_DIR" ] || [ -z "$(ls -A "$LABS_DIR" 2>/dev/null)" ]; then
    echo "No labs found."
    echo ""
    echo "Generate a lab with:"
    echo "  ./generators/generate-lab.sh <type> <name>"
    exit 0
fi

# List labs
for lab_dir in "$LABS_DIR"/*/; do
    if [ -d "$lab_dir" ]; then
        lab_name=$(basename "$lab_dir")
        lab_yaml="$lab_dir/lab.yaml"

        # Get lab info
        if [ -f "$lab_yaml" ]; then
            lab_type=$(grep "type:" "$lab_yaml" 2>/dev/null | cut -d'"' -f2 || echo "unknown")
            difficulty=$(grep "difficulty:" "$lab_yaml" 2>/dev/null | cut -d'"' -f2 || echo "unknown")
            flags=$(grep "total:" "$lab_yaml" 2>/dev/null | awk '{print $2}' || echo "?")
        else
            lab_type="unknown"
            difficulty="unknown"
            flags="?"
        fi

        # Check if running
        status="stopped"
        if [ -f "$lab_dir/docker-compose.yml" ]; then
            running=$(docker-compose -f "$lab_dir/docker-compose.yml" ps -q 2>/dev/null | wc -l)
            if [ "$running" -gt 0 ]; then
                status="${GREEN}running${NC}"
            fi
        fi

        if [ "$SHOW_RUNNING" = "--running" ] && [ "$status" = "stopped" ]; then
            continue
        fi

        echo -e "${BLUE}$lab_name${NC}"
        echo "  Type:       $lab_type"
        echo "  Difficulty: $difficulty"
        echo "  Flags:      $flags"
        echo -e "  Status:     $status"
        echo ""
    fi
done

echo "========================================"
echo "Commands:"
echo "  Start lab:  cd labs/<name> && docker-compose up -d"
echo "  Stop lab:   cd labs/<name> && docker-compose down"
echo "========================================"
