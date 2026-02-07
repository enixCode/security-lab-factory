# Flag System

This directory contains the FLAG system for CTF challenges and skill verification.

## Directory Structure

```
flags/
├── README.md           # This file
├── validators/         # Skill verification scripts
│   ├── web/           # Web security validators
│   ├── network/       # Network security validators
│   ├── cloud/         # Cloud security validators
│   └── dev/           # Development validators
└── solutions/          # Encrypted flag solutions (for lab creators)
```

## CTF Flags

### Flag Format
All CTF flags follow this format:
```
FLAG{category_description_random}
```

### Examples
- `FLAG{sqli_union_injection_a3f2c1}`
- `FLAG{privesc_suid_binary_x9y8z7}`
- `FLAG{ssrf_cloud_metadata_pwned}`

### Difficulty Levels
- **Easy**: 100 points
- **Medium**: 250 points
- **Hard**: 500 points
- **Expert**: 1000 points

## Skill Validators

Validators are scripts that verify if a task was completed correctly.

### Validator Structure
```bash
#!/bin/bash
# Validator: check_[skill_name].sh
# Description: What this validator checks
# Expected: What should pass
# Returns: 0 = PASS, 1 = FAIL

# Your validation logic here
if [condition]; then
    echo "PASS: Description of success"
    exit 0
else
    echo "FAIL: Description of failure"
    exit 1
fi
```

### Running Validators
```bash
# Single validator
./validators/web/check_sqli_fixed.sh

# All validators for a category
./run-validators.sh web

# All validators
./run-validators.sh all
```

## Creating New Flags

1. Generate a unique flag:
```bash
./generators/generate-flag.sh "sqli" "union based injection"
# Output: FLAG{sqli_union_based_injection_a3f2}
```

2. Add flag to the lab's docker-compose.yml:
```yaml
environment:
  - FLAG_1=FLAG{sqli_union_based_injection_a3f2}
```

3. Hide the flag appropriately:
   - In files: `/root/flag.txt`, `/home/user/.secret`
   - In databases: Hidden table/column
   - In memory: Environment variable
   - In binaries: Encoded strings

4. Document in solutions/ (base64 encoded):
```bash
echo "FLAG{...} is in /root/flag.txt" | base64 >> solutions/lab_name.txt
```

## Validator Examples

### Web - Check SQL Injection Fixed
```bash
#!/bin/bash
if grep -rq "prepare\|parameterized" /app/*.php; then
    echo "PASS: SQL injection mitigated with prepared statements"
    exit 0
else
    echo "FAIL: No prepared statements found"
    exit 1
fi
```

### Network - Check Firewall Rules
```bash
#!/bin/bash
if iptables -L | grep -q "DROP.*22"; then
    echo "PASS: SSH port is blocked"
    exit 0
else
    echo "FAIL: SSH port is still open"
    exit 1
fi
```

### Cloud - Check S3 Bucket Private
```bash
#!/bin/bash
acl=$(aws s3api get-bucket-acl --bucket target-bucket 2>/dev/null)
if echo "$acl" | grep -q "private"; then
    echo "PASS: S3 bucket is private"
    exit 0
else
    echo "FAIL: S3 bucket is public"
    exit 1
fi
```
