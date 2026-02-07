# Security Lab Factory

A Docker-based laboratory generation system for security testing, CTF challenges, and development environments.

## Features

- **Multiple Lab Types**: Web security, network pentesting, cloud security, CTF challenges, development environments
- **Full-Stack Domains**: Web, network, cloud, reverse engineering, forensics, DevOps
- **FLAG System**: CTF-style flags + automated skill validators
- **Docker Compose**: All labs run in isolated Docker environments
- **Claude Code Integration**: CLAUDE.md provides instructions for AI-assisted lab generation

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/security-lab-factory.git
cd security-lab-factory

# Generate a new lab
./generators/generate-lab.sh web my-first-lab --flags 5 --difficulty medium

# Start the lab
cd labs/my-first-lab
docker-compose up -d

# Check status
docker-compose ps

# Stop the lab
docker-compose down -v
```

## Directory Structure

```
security-lab-factory/
├── CLAUDE.md                    # AI assistant instructions
├── README.md                    # This file
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
├── labs/                        # Generated labs (gitignored)
├── flags/                       # Flag system
│   ├── validators/             # Skill verification scripts
│   └── solutions/              # Encrypted solutions
└── generators/                  # Generation scripts
```

## Lab Types

### Web Security Labs
OWASP Top 10 vulnerabilities, including:
- SQL Injection (basic, UNION, blind)
- XSS (reflected, stored, DOM)
- SSRF, CSRF, XXE
- Authentication flaws
- File upload vulnerabilities

```bash
./generators/generate-lab.sh web sqli-lab --difficulty medium
```

### Network Labs
Network penetration testing environments:
- Active Directory attacks
- Lateral movement
- Privilege escalation
- Network protocol attacks

```bash
./generators/generate-lab.sh network ad-lab --difficulty hard
```

### Cloud Security Labs
Cloud infrastructure security (LocalStack-based):
- AWS IAM privilege escalation
- S3 bucket misconfigurations
- SSRF to cloud metadata
- Kubernetes security

```bash
./generators/generate-lab.sh cloud aws-lab --difficulty medium
```

### CTF Challenges
Capture The Flag environments:
- Multiple challenge categories
- Scoring system (CTFd)
- Flag submission and tracking

```bash
./generators/generate-lab.sh ctf my-ctf --flags 20
```

### Development Environments
Full-stack development setups:
- Node.js, Python, Go
- PostgreSQL, MongoDB, Redis
- Hot reload, debugging
- Testing frameworks

```bash
./generators/generate-lab.sh dev fullstack-dev
```

## Flag System

### CTF Flags
Format: `FLAG{category_description_random}`

Example flags:
- `FLAG{sqli_union_injection_a3f2c1}`
- `FLAG{privesc_suid_binary_x9y8z7}`
- `FLAG{ssrf_cloud_metadata_pwned}`

### Skill Validators
Automated scripts that verify task completion:

```bash
# Run all validators
./flags/validators/run-validators.sh all

# Run specific category
./flags/validators/run-validators.sh web
```

## Using with Claude Code

This repository includes `CLAUDE.md` which provides instructions for Claude Code to generate labs automatically.

Example prompts:
- "Generate a SQL injection lab with 5 flags"
- "Create an Active Directory penetration testing environment"
- "Set up a Node.js development environment with PostgreSQL"
- "Build a CTF challenge for web security"

## Templates

### Available Templates

| Template | Description | Services |
|----------|-------------|----------|
| `web-security-lab.yaml` | DVWA, Juice Shop, WebGoat | 5 |
| `ctf-base.yaml` | CTFd, challenges, attacker | 7+ |
| `pentest-lab.yaml` | Network pentest environment | 8 |
| `aws-localstack.yaml` | AWS security testing | 5 |
| `fullstack-dev.yaml` | Dev environment | 7 |

### Customizing Templates

1. Copy a template to `labs/your-lab/`
2. Modify `docker-compose.yml` as needed
3. Add custom challenges to `challenges/`
4. Generate flags with `./generators/generate-flag.sh`

## Requirements

- Docker Engine 20.10+
- Docker Compose v2
- 8GB+ RAM recommended
- 20GB+ disk space

## Security Notice

These labs contain intentionally vulnerable applications. **Never expose them to untrusted networks or the internet.**

Best practices:
- Run labs in isolated networks
- Use Docker's network isolation
- Stop labs when not in use
- Clean up with `docker-compose down -v`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add new skills, templates, or validators
4. Submit a pull request

## License

MIT License - Use freely for educational purposes.

## Resources

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [HackTricks](https://book.hacktricks.xyz/)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [Docker Security](https://docs.docker.com/engine/security/)
