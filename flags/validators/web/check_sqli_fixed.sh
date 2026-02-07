#!/bin/bash
# Validator: check_sqli_fixed.sh
# Description: Checks if SQL injection vulnerabilities have been fixed
# Checks for: Prepared statements, parameterized queries, input validation
# Returns: 0 = PASS (fixed), 1 = FAIL (still vulnerable)

set -e

APP_PATH="${1:-/app}"
SCORE=0
TOTAL_CHECKS=4

echo "=== SQL Injection Fix Validator ==="
echo "Checking: $APP_PATH"
echo ""

# Check 1: Prepared statements in PHP
echo "[1/4] Checking for prepared statements (PHP)..."
if find "$APP_PATH" -name "*.php" -exec grep -l "prepare\|bindParam\|bindValue" {} \; 2>/dev/null | grep -q .; then
    echo "  ✓ Prepared statements found"
    ((SCORE++))
else
    echo "  ✗ No prepared statements found in PHP files"
fi

# Check 2: Parameterized queries (Python)
echo "[2/4] Checking for parameterized queries (Python)..."
if find "$APP_PATH" -name "*.py" -exec grep -l "execute.*%" {} \; 2>/dev/null | grep -q .; then
    echo "  ✗ String formatting in SQL queries detected"
else
    echo "  ✓ No string formatting in SQL queries"
    ((SCORE++))
fi

# Check 3: ORM usage
echo "[3/4] Checking for ORM usage..."
if find "$APP_PATH" \( -name "*.py" -o -name "*.php" -o -name "*.js" \) -exec grep -l "sqlalchemy\|eloquent\|sequelize\|prisma\|typeorm" {} \; 2>/dev/null | grep -q .; then
    echo "  ✓ ORM detected (safer than raw SQL)"
    ((SCORE++))
else
    echo "  ○ No ORM detected (not necessarily bad)"
    ((SCORE++))  # Neutral, don't penalize
fi

# Check 4: No direct concatenation
echo "[4/4] Checking for SQL string concatenation..."
CONCAT_FOUND=$(find "$APP_PATH" -name "*.php" -exec grep -l "SELECT.*\.\s*\$\|INSERT.*\.\s*\$\|UPDATE.*\.\s*\$" {} \; 2>/dev/null | wc -l)
if [ "$CONCAT_FOUND" -eq 0 ]; then
    echo "  ✓ No dangerous SQL concatenation found"
    ((SCORE++))
else
    echo "  ✗ Found $CONCAT_FOUND files with SQL string concatenation"
fi

echo ""
echo "=== Results ==="
echo "Score: $SCORE / $TOTAL_CHECKS"

if [ $SCORE -ge 3 ]; then
    echo "Status: PASS - SQL injection vulnerabilities appear to be mitigated"
    exit 0
else
    echo "Status: FAIL - SQL injection vulnerabilities may still exist"
    exit 1
fi
