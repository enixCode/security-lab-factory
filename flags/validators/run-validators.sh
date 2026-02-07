#!/bin/bash
# Run validators for a specific category or all categories
# Usage: ./run-validators.sh [category|all]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATEGORY="${1:-all}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0

run_validators_in_dir() {
    local dir="$1"
    local category_name="$2"

    echo ""
    echo "=========================================="
    echo " Running $category_name validators"
    echo "=========================================="

    for validator in "$dir"/*.sh; do
        if [ -f "$validator" ] && [ "$(basename "$validator")" != "run-validators.sh" ]; then
            echo ""
            echo "--- $(basename "$validator") ---"

            if bash "$validator" 2>/dev/null; then
                echo -e "${GREEN}[PASSED]${NC}"
                ((PASSED++))
            else
                exit_code=$?
                if [ $exit_code -eq 127 ]; then
                    echo -e "${YELLOW}[SKIPPED]${NC} - Missing dependencies"
                    ((SKIPPED++))
                else
                    echo -e "${RED}[FAILED]${NC}"
                    ((FAILED++))
                fi
            fi
        fi
    done
}

echo "========================================"
echo "   Security Lab Validator Runner"
echo "========================================"
echo "Category: $CATEGORY"
echo "Time: $(date)"

case "$CATEGORY" in
    web)
        run_validators_in_dir "$SCRIPT_DIR/web" "Web Security"
        ;;
    network)
        run_validators_in_dir "$SCRIPT_DIR/network" "Network Security"
        ;;
    cloud)
        run_validators_in_dir "$SCRIPT_DIR/cloud" "Cloud Security"
        ;;
    dev)
        run_validators_in_dir "$SCRIPT_DIR/dev" "Development"
        ;;
    all)
        for category_dir in "$SCRIPT_DIR"/*/; do
            if [ -d "$category_dir" ]; then
                category_name=$(basename "$category_dir")
                run_validators_in_dir "$category_dir" "$category_name"
            fi
        done
        ;;
    *)
        echo "Unknown category: $CATEGORY"
        echo "Usage: $0 [web|network|cloud|dev|all]"
        exit 1
        ;;
esac

echo ""
echo "========================================"
echo "           Final Results"
echo "========================================"
echo -e "Passed:  ${GREEN}$PASSED${NC}"
echo -e "Failed:  ${RED}$FAILED${NC}"
echo -e "Skipped: ${YELLOW}$SKIPPED${NC}"
echo "========================================"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All validators passed!${NC}"
    exit 0
else
    echo -e "${RED}Some validators failed.${NC}"
    exit 1
fi
