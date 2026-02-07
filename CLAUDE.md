# Security Lab Factory - Claude Code Instructions

## Project Overview
This repository is a **laboratory generation system** that creates Docker-based environments for security testing, development, CTF challenges, and skill verification.

## How to Generate Labs

When the user asks to generate a lab, follow this process:

### 1. Identify the Lab Type
- **Security Labs**: Vulnerability testing, penetration testing, OWASP challenges
- **CTF Labs**: Capture The Flag challenges with hidden flags
- **Development Labs**: Dev environments, CI/CD, testing frameworks
- **Network Labs**: Network security, Active Directory, infrastructure
- **Cloud Labs**: AWS, Azure, GCP security scenarios
- **Forensics Labs**: Digital forensics, incident response
- **Reverse Engineering Labs**: Binary analysis, malware analysis

### 2. Check the Skills Files
Read the appropriate skills file from `skills/` directory to understand:
- Available challenges and scenarios
- Difficulty levels
- Required components
- Learning objectives

### 3. Generate Docker Compose
Create a `docker-compose.yml` in the `labs/` directory with:
```yaml
# Lab: [LAB_NAME]
# Difficulty: [easy|medium|hard|expert]
# Domain: [domain from skills/]
# Description: [what this lab teaches]
# Flags: [number of flags to find]

version: '3.8'
services:
  # ... services
```

### 4. Generate Flags
For CTF-style labs:
- Create flags in format: `FLAG{descriptive_flag_name_here}`
- Hide flags in realistic locations (config files, databases, memory, etc.)
- Document flag locations in `flags/solutions/[lab_name].md` (encrypted or base64)

For skill verification:
- Create validator scripts in `flags/validators/`
- Scripts should return exit code 0 on success

## Lab Generation Commands

When user says:
- **"generate web security lab"** → Use `skills/web-security/` templates
- **"create CTF challenge"** → Include FLAGS and scoring
- **"build dev environment"** → Use `skills/development/` templates
- **"network pentest lab"** → Use `skills/network-security/` templates

## Directory Structure

```
security-lab-factory/
├── CLAUDE.md                    # This file
├── README.md                    # User documentation
├── skills/                      # Skill domains and challenges
│   ├── web-security/           # OWASP, XSS, SQLi, SSRF, etc.
│   ├── network-security/       # Network attacks, AD, pivoting
│   ├── cloud-security/         # AWS, Azure, GCP security
│   ├── reverse-engineering/    # Binary analysis, malware
│   ├── forensics/              # DFIR, memory analysis
│   ├── devops/                 # CI/CD security, containers
│   └── development/            # Dev environments, testing
├── templates/                   # Docker Compose templates
│   ├── vulnerable-apps/        # Intentionally vulnerable apps
│   ├── ctf-challenges/         # CTF challenge templates
│   ├── dev-environments/       # Development setups
│   ├── network-labs/           # Network infrastructure
│   └── cloud-labs/             # Cloud simulation
├── labs/                        # Generated labs go here
├── flags/                       # Flag system
│   ├── validators/             # Skill verification scripts
│   └── solutions/              # Encrypted solutions
└── generators/                  # Generation scripts
```

## Flag System

### CTF Flags
Format: `FLAG{category_description_random}`
Example: `FLAG{sqli_union_based_injection_a3f2}`

Locations to hide flags:
- `/root/flag.txt` (simple)
- Database records
- Environment variables
- Binary files (strings)
- Memory dumps
- Log files
- Hidden services

### Skill Validators
Create bash scripts that verify task completion:
```bash
#!/bin/bash
# Validator: check_sql_injection_fixed.sh
# Returns 0 if vulnerability is patched

if grep -q "prepared_statement" /app/db.php; then
    echo "PASS: SQL injection vulnerability fixed"
    exit 0
else
    echo "FAIL: SQL injection still present"
    exit 1
fi
```

## Web Search for Lab Generation

When generating labs, search the web for:
- Latest CVEs for realistic scenarios
- Updated vulnerable application versions
- Current attack techniques
- Best practices for the technology stack

## Quick Generation Examples

### Example 1: Web Security Lab
```
User: "Generate a SQL injection lab"
Action:
1. Read skills/web-security/sqli.yaml
2. Create labs/sqli-lab/docker-compose.yml
3. Include vulnerable PHP app + MySQL
4. Add 3 flags of increasing difficulty
5. Create validator for fix verification
```

### Example 2: Network Lab
```
User: "Create Active Directory lab"
Action:
1. Read skills/network-security/active-directory.yaml
2. Create labs/ad-lab/docker-compose.yml
3. Include DC, workstations, vulnerable configs
4. Add flags for each privilege escalation step
```

### Example 3: Development Lab
```
User: "Set up a Node.js dev environment"
Action:
1. Read skills/development/nodejs.yaml
2. Create labs/nodejs-dev/docker-compose.yml
3. Include Node, MongoDB, Redis, debugging tools
4. Add hot-reload and testing frameworks
```

## Important Rules

1. **Always use Docker** - All labs must be containerized
2. **Document everything** - Each lab needs clear instructions
3. **Isolated networks** - Use Docker networks for isolation
4. **Realistic scenarios** - Base labs on real-world situations
5. **Progressive difficulty** - Include easy, medium, hard challenges
6. **Clean teardown** - Provide `docker-compose down -v` instructions
7. **Resource limits** - Set memory/CPU limits for containers

## Lab Metadata Format

Each generated lab must include a `lab.yaml`:
```yaml
name: "Lab Name"
version: "1.0"
difficulty: medium
domain: web-security
time_estimate: "2-4 hours"
skills_tested:
  - SQL Injection
  - Authentication Bypass
  - Privilege Escalation
flags:
  total: 5
  points: 500
prerequisites:
  - Basic SQL knowledge
  - Linux command line
resources:
  memory: "4GB"
  cpu: "2 cores"
```
