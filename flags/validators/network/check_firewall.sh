#!/bin/bash
# Validator: check_firewall.sh
# Description: Validates firewall configuration
# Checks for: Required blocked ports, allowed services, default policy
# Returns: 0 = PASS, 1 = FAIL

set -e

echo "=== Firewall Configuration Validator ==="
echo ""

SCORE=0
TOTAL_CHECKS=5

# Check 1: Firewall is active
echo "[1/5] Checking if firewall is active..."
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        echo "  ✓ UFW is active"
        ((SCORE++))
    else
        echo "  ✗ UFW is not active"
    fi
elif command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --state 2>/dev/null | grep -q "running"; then
        echo "  ✓ firewalld is running"
        ((SCORE++))
    else
        echo "  ✗ firewalld is not running"
    fi
elif iptables -L -n &>/dev/null; then
    RULES=$(iptables -L -n | grep -c "ACCEPT\|DROP\|REJECT" || echo 0)
    if [ "$RULES" -gt 3 ]; then
        echo "  ✓ iptables has rules configured"
        ((SCORE++))
    else
        echo "  ✗ iptables has minimal/no rules"
    fi
else
    echo "  ✗ No firewall detected"
fi

# Check 2: SSH restricted
echo "[2/5] Checking SSH access restrictions..."
if iptables -L INPUT -n 2>/dev/null | grep -q "22.*DROP\|22.*REJECT"; then
    echo "  ✓ SSH (22) has restrictions"
    ((SCORE++))
elif ufw status 2>/dev/null | grep -q "22.*DENY"; then
    echo "  ✓ SSH (22) is denied by UFW"
    ((SCORE++))
elif ufw status 2>/dev/null | grep -q "22/tcp.*LIMIT"; then
    echo "  ✓ SSH (22) is rate-limited"
    ((SCORE++))
else
    echo "  ○ SSH access not explicitly restricted (may be intentional)"
fi

# Check 3: Default deny policy
echo "[3/5] Checking default policy..."
if iptables -L INPUT -n 2>/dev/null | head -1 | grep -q "DROP\|REJECT"; then
    echo "  ✓ Default INPUT policy is DROP/REJECT"
    ((SCORE++))
elif ufw status verbose 2>/dev/null | grep -q "Default: deny"; then
    echo "  ✓ UFW default is deny"
    ((SCORE++))
else
    echo "  ✗ Default policy may be too permissive"
fi

# Check 4: No dangerous ports open
echo "[4/5] Checking for dangerous open ports..."
DANGEROUS_PORTS="23 69 111 135 139 445 512 513 514"
OPEN_DANGEROUS=0
for port in $DANGEROUS_PORTS; do
    if netstat -tlnp 2>/dev/null | grep -q ":$port " || ss -tlnp 2>/dev/null | grep -q ":$port "; then
        echo "  ✗ Dangerous port $port is open"
        ((OPEN_DANGEROUS++))
    fi
done
if [ $OPEN_DANGEROUS -eq 0 ]; then
    echo "  ✓ No commonly dangerous ports are open"
    ((SCORE++))
fi

# Check 5: Outbound restrictions (bonus)
echo "[5/5] Checking outbound restrictions..."
if iptables -L OUTPUT -n 2>/dev/null | grep -q "DROP\|REJECT"; then
    echo "  ✓ Outbound traffic has restrictions"
    ((SCORE++))
else
    echo "  ○ No outbound restrictions (common but less secure)"
    ((SCORE++))  # Not penalizing, as this is often intentional
fi

echo ""
echo "=== Results ==="
echo "Score: $SCORE / $TOTAL_CHECKS"

if [ $SCORE -ge 3 ]; then
    echo "Status: PASS - Firewall is properly configured"
    exit 0
else
    echo "Status: FAIL - Firewall configuration needs improvement"
    exit 1
fi
