#!/bin/bash
# Validator: check_s3_security.sh
# Description: Validates S3 bucket security configuration
# Checks for: Public access, encryption, versioning, logging
# Returns: 0 = PASS, 1 = FAIL

set -e

BUCKET_NAME="${1:-target-bucket}"
AWS_ENDPOINT="${AWS_ENDPOINT_URL:-}"

echo "=== S3 Security Validator ==="
echo "Bucket: $BUCKET_NAME"
echo ""

SCORE=0
TOTAL_CHECKS=5

# Build AWS CLI command with optional endpoint
AWS_CMD="aws s3api"
if [ -n "$AWS_ENDPOINT" ]; then
    AWS_CMD="aws --endpoint-url=$AWS_ENDPOINT s3api"
fi

# Check 1: Block Public Access
echo "[1/5] Checking Block Public Access settings..."
PUBLIC_ACCESS=$($AWS_CMD get-public-access-block --bucket "$BUCKET_NAME" 2>/dev/null || echo "NOTSET")
if echo "$PUBLIC_ACCESS" | grep -q '"BlockPublicAcls": true' && \
   echo "$PUBLIC_ACCESS" | grep -q '"BlockPublicPolicy": true'; then
    echo "  ✓ Block Public Access is enabled"
    ((SCORE++))
elif echo "$PUBLIC_ACCESS" | grep -q "NOTSET"; then
    echo "  ✗ Block Public Access is not configured"
else
    echo "  ✗ Block Public Access is not fully enabled"
fi

# Check 2: Bucket ACL is private
echo "[2/5] Checking bucket ACL..."
ACL=$($AWS_CMD get-bucket-acl --bucket "$BUCKET_NAME" 2>/dev/null || echo "ERROR")
if echo "$ACL" | grep -q "AllUsers\|AuthenticatedUsers"; then
    echo "  ✗ Bucket has public ACL grants"
else
    echo "  ✓ Bucket ACL is private"
    ((SCORE++))
fi

# Check 3: Server-side encryption
echo "[3/5] Checking encryption..."
ENCRYPTION=$($AWS_CMD get-bucket-encryption --bucket "$BUCKET_NAME" 2>/dev/null || echo "NONE")
if echo "$ENCRYPTION" | grep -q "AES256\|aws:kms"; then
    echo "  ✓ Server-side encryption is enabled"
    ((SCORE++))
else
    echo "  ✗ Server-side encryption is not enabled"
fi

# Check 4: Versioning enabled
echo "[4/5] Checking versioning..."
VERSIONING=$($AWS_CMD get-bucket-versioning --bucket "$BUCKET_NAME" 2>/dev/null || echo "DISABLED")
if echo "$VERSIONING" | grep -q '"Status": "Enabled"'; then
    echo "  ✓ Versioning is enabled"
    ((SCORE++))
else
    echo "  ○ Versioning is not enabled (recommended for data protection)"
fi

# Check 5: Access logging
echo "[5/5] Checking access logging..."
LOGGING=$($AWS_CMD get-bucket-logging --bucket "$BUCKET_NAME" 2>/dev/null || echo "DISABLED")
if echo "$LOGGING" | grep -q "TargetBucket"; then
    echo "  ✓ Access logging is enabled"
    ((SCORE++))
else
    echo "  ○ Access logging is not enabled (recommended for auditing)"
fi

echo ""
echo "=== Results ==="
echo "Score: $SCORE / $TOTAL_CHECKS"

if [ $SCORE -ge 3 ]; then
    echo "Status: PASS - S3 bucket has good security configuration"
    exit 0
else
    echo "Status: FAIL - S3 bucket security needs improvement"
    exit 1
fi
