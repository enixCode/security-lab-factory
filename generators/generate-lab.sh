#!/bin/bash
# Lab Generator Script
# Generates a new lab environment from templates
# Usage: ./generate-lab.sh <lab-type> <lab-name> [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$ROOT_DIR/templates"
LABS_DIR="$ROOT_DIR/labs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo "Lab Generator - Security Lab Factory"
    echo ""
    echo "Usage: $0 <lab-type> <lab-name> [options]"
    echo ""
    echo "Lab Types:"
    echo "  web         Web security lab (DVWA, Juice Shop, etc.)"
    echo "  ctf         CTF challenge environment"
    echo "  network     Network penetration testing lab"
    echo "  cloud       Cloud security lab (LocalStack)"
    echo "  dev         Development environment"
    echo ""
    echo "Options:"
    echo "  --flags N       Number of flags to generate (default: 3)"
    echo "  --difficulty D  Difficulty level: easy, medium, hard, expert"
    echo "  --start         Start the lab after generation"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 web my-sqli-lab --flags 5 --difficulty medium"
    echo "  $0 ctf my-ctf --flags 10 --start"
    echo "  $0 network pentest-lab --difficulty hard"
}

generate_flag() {
    local category="$1"
    local description="$2"
    local random_suffix=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 6 | head -n 1)
    local clean_desc=$(echo "$description" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')
    echo "FLAG{${category}_${clean_desc}_${random_suffix}}"
}

generate_lab_yaml() {
    local lab_name="$1"
    local lab_type="$2"
    local difficulty="$3"
    local num_flags="$4"
    local lab_dir="$5"

    cat > "$lab_dir/lab.yaml" << EOF
# Lab Configuration
name: "$lab_name"
version: "1.0"
type: "$lab_type"
difficulty: "$difficulty"
created: "$(date -Iseconds)"
generator: "security-lab-factory"

# Challenge Information
flags:
  total: $num_flags
  format: "FLAG{category_description_random}"

# Resources
resources:
  memory: "4GB"
  cpu: "2 cores"
  disk: "10GB"

# Instructions
instructions: |
  1. Start the lab: docker-compose up -d
  2. Access the services on their respective ports
  3. Find all $num_flags flags hidden in the environment
  4. Submit flags to verify completion

# Cleanup
cleanup: |
  docker-compose down -v
  docker system prune -f
EOF
}

# Parse arguments
LAB_TYPE=""
LAB_NAME=""
NUM_FLAGS=3
DIFFICULTY="medium"
START_LAB=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --flags)
            NUM_FLAGS="$2"
            shift 2
            ;;
        --difficulty)
            DIFFICULTY="$2"
            shift 2
            ;;
        --start)
            START_LAB=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
        *)
            if [ -z "$LAB_TYPE" ]; then
                LAB_TYPE="$1"
            elif [ -z "$LAB_NAME" ]; then
                LAB_NAME="$1"
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [ -z "$LAB_TYPE" ] || [ -z "$LAB_NAME" ]; then
    echo -e "${RED}Error: Lab type and name are required${NC}"
    show_help
    exit 1
fi

# Create lab directory
LAB_DIR="$LABS_DIR/$LAB_NAME"
if [ -d "$LAB_DIR" ]; then
    echo -e "${YELLOW}Warning: Lab '$LAB_NAME' already exists${NC}"
    read -p "Overwrite? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        exit 1
    fi
    rm -rf "$LAB_DIR"
fi

mkdir -p "$LAB_DIR"
mkdir -p "$LAB_DIR/challenges"
mkdir -p "$LAB_DIR/flags"

echo -e "${BLUE}Generating lab: $LAB_NAME${NC}"
echo "Type: $LAB_TYPE"
echo "Difficulty: $DIFFICULTY"
echo "Flags: $NUM_FLAGS"
echo ""

# Copy template based on type
case $LAB_TYPE in
    web)
        cp "$TEMPLATES_DIR/vulnerable-apps/web-security-lab.yaml" "$LAB_DIR/docker-compose.yml"
        ;;
    ctf)
        cp "$TEMPLATES_DIR/ctf-challenges/ctf-base.yaml" "$LAB_DIR/docker-compose.yml"
        ;;
    network)
        cp "$TEMPLATES_DIR/network-labs/pentest-lab.yaml" "$LAB_DIR/docker-compose.yml"
        ;;
    cloud)
        cp "$TEMPLATES_DIR/cloud-labs/aws-localstack.yaml" "$LAB_DIR/docker-compose.yml"
        ;;
    dev)
        cp "$TEMPLATES_DIR/dev-environments/fullstack-dev.yaml" "$LAB_DIR/docker-compose.yml"
        ;;
    *)
        echo -e "${RED}Unknown lab type: $LAB_TYPE${NC}"
        show_help
        exit 1
        ;;
esac

# Generate flags
echo "Generating flags..."
FLAGS_FILE="$LAB_DIR/flags/flags.txt"
SOLUTIONS_FILE="$LAB_DIR/flags/solutions.txt.b64"

for i in $(seq 1 $NUM_FLAGS); do
    flag=$(generate_flag "$LAB_TYPE" "challenge_$i")
    echo "$flag" >> "$FLAGS_FILE"
    echo "  Flag $i: $flag"
done

# Encode solutions (for lab creators)
base64 "$FLAGS_FILE" > "$SOLUTIONS_FILE"
echo "Solutions encoded to: flags/solutions.txt.b64"

# Generate lab.yaml
generate_lab_yaml "$LAB_NAME" "$LAB_TYPE" "$DIFFICULTY" "$NUM_FLAGS" "$LAB_DIR"

# Create README
cat > "$LAB_DIR/README.md" << EOF
# $LAB_NAME

**Type:** $LAB_TYPE
**Difficulty:** $DIFFICULTY
**Flags:** $NUM_FLAGS

## Quick Start

\`\`\`bash
# Start the lab
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop the lab
docker-compose down -v
\`\`\`

## Objectives

Find all $NUM_FLAGS flags hidden in this environment.

Flag format: \`FLAG{category_description_random}\`

## Services

Check \`docker-compose.yml\` for available services and ports.

## Hints

1. Start with reconnaissance
2. Check for common vulnerabilities
3. Escalate privileges when possible
4. Document your findings

## Solution

Solutions are encoded in \`flags/solutions.txt.b64\`.
Decode with: \`base64 -d flags/solutions.txt.b64\`

---
Generated by Security Lab Factory
EOF

echo ""
echo -e "${GREEN}Lab generated successfully!${NC}"
echo "Location: $LAB_DIR"
echo ""

# Start lab if requested
if [ "$START_LAB" = true ]; then
    echo "Starting lab..."
    cd "$LAB_DIR"
    docker-compose up -d
    echo ""
    docker-compose ps
fi

echo ""
echo "Next steps:"
echo "  cd $LAB_DIR"
echo "  docker-compose up -d"
