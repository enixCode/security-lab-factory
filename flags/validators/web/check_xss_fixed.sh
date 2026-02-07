#!/bin/bash
# Validator: check_xss_fixed.sh
# Description: Checks if XSS vulnerabilities have been fixed
# Checks for: Output encoding, CSP headers, input sanitization
# Returns: 0 = PASS (fixed), 1 = FAIL (still vulnerable)

set -e

APP_PATH="${1:-/app}"
URL="${2:-http://localhost:8080}"
SCORE=0
TOTAL_CHECKS=5

echo "=== XSS Fix Validator ==="
echo "Checking: $APP_PATH"
echo "URL: $URL"
echo ""

# Check 1: HTML encoding functions
echo "[1/5] Checking for HTML encoding..."
if find "$APP_PATH" -name "*.php" -exec grep -l "htmlspecialchars\|htmlentities" {} \; 2>/dev/null | grep -q .; then
    echo "  ✓ HTML encoding functions found (PHP)"
    ((SCORE++))
elif find "$APP_PATH" -name "*.py" -exec grep -l "escape\|bleach\|markupsafe" {} \; 2>/dev/null | grep -q .; then
    echo "  ✓ HTML encoding functions found (Python)"
    ((SCORE++))
elif find "$APP_PATH" -name "*.js" -exec grep -l "DOMPurify\|sanitize\|escapeHtml" {} \; 2>/dev/null | grep -q .; then
    echo "  ✓ HTML sanitization found (JavaScript)"
    ((SCORE++))
else
    echo "  ✗ No HTML encoding/sanitization found"
fi

# Check 2: Template auto-escaping
echo "[2/5] Checking for template auto-escaping..."
if find "$APP_PATH" -name "*.html" -name "*.twig" -name "*.jinja2" 2>/dev/null | head -1 | grep -q .; then
    echo "  ✓ Using templating engine (likely auto-escapes)"
    ((SCORE++))
elif find "$APP_PATH" -name "*.jsx" -name "*.tsx" 2>/dev/null | head -1 | grep -q .; then
    echo "  ✓ Using React (auto-escapes by default)"
    ((SCORE++))
else
    echo "  ○ Template engine status unknown"
fi

# Check 3: No innerHTML usage (DOM XSS)
echo "[3/5] Checking for dangerous DOM methods..."
INNERHTML_COUNT=$(find "$APP_PATH" -name "*.js" -exec grep -c "innerHTML\s*=" {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
if [ "${INNERHTML_COUNT:-0}" -eq 0 ]; then
    echo "  ✓ No innerHTML assignments found"
    ((SCORE++))
else
    echo "  ✗ Found innerHTML usage ($INNERHTML_COUNT occurrences)"
fi

# Check 4: Content Security Policy
echo "[4/5] Checking for CSP headers..."
if command -v curl &> /dev/null && curl -sI "$URL" 2>/dev/null | grep -qi "content-security-policy"; then
    echo "  ✓ CSP header is set"
    ((SCORE++))
else
    echo "  ✗ No CSP header detected"
fi

# Check 5: No eval() or document.write()
echo "[5/5] Checking for dangerous JavaScript functions..."
DANGEROUS=$(find "$APP_PATH" -name "*.js" -exec grep -c "eval(\|document\.write(" {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
if [ "${DANGEROUS:-0}" -eq 0 ]; then
    echo "  ✓ No eval() or document.write() found"
    ((SCORE++))
else
    echo "  ✗ Found dangerous functions ($DANGEROUS occurrences)"
fi

echo ""
echo "=== Results ==="
echo "Score: $SCORE / $TOTAL_CHECKS"

if [ $SCORE -ge 4 ]; then
    echo "Status: PASS - XSS vulnerabilities appear to be mitigated"
    exit 0
else
    echo "Status: FAIL - XSS vulnerabilities may still exist"
    exit 1
fi
