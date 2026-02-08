# Lab Store & Export System

This directory contains tools for packaging, exporting, and sharing labs.

## Overview

The Lab Store system allows you to:
- **Package** labs into distributable formats
- **Export** labs for sharing or selling
- **Import** labs from the community
- **Monetize** premium lab content

## Export Formats

### 1. Docker Bundle (`.lab.tar.gz`)
Complete lab package with all resources.
```bash
./export-lab.sh my-lab --format docker
```

### 2. Terraform Module
Export as Terraform-compatible infrastructure.
```bash
./export-lab.sh my-lab --format terraform
```

### 3. Kubernetes Manifests
Export as K8s YAML manifests.
```bash
./export-lab.sh my-lab --format kubernetes
```

### 4. OVA/OVF (Virtual Machine)
Export as virtual machine image.
```bash
./export-lab.sh my-lab --format ova
```

## Lab Metadata

Each lab package includes:
```yaml
# lab-manifest.yaml
name: "SQL Injection Lab"
version: "1.0.0"
author: "Your Name"
license: "MIT" # or "Commercial"
price: 0  # 0 = free
difficulty: medium
duration: "2-4 hours"
skills:
  - SQL Injection
  - Database Security
requirements:
  - Docker
  - 4GB RAM
checksum: "sha256:abc123..."
```

## Monetization Options

### Free Labs
- Open source, community shared
- MIT/Apache licensed
- Hosted on GitHub

### Premium Labs
- Advanced scenarios
- Commercial license
- Sold through marketplace

### Subscription Model
- Monthly lab access
- New labs added regularly
- Enterprise licensing

## Marketplace Integration

### Gumroad
```bash
./store/publish.sh my-lab --platform gumroad
```

### GitHub Marketplace
```bash
./store/publish.sh my-lab --platform github
```

### Self-Hosted Store
```bash
./store/start-store.sh
```

## Directory Structure

```
store/
├── README.md           # This file
├── export-lab.sh       # Export labs to various formats
├── import-lab.sh       # Import labs from packages
├── publish.sh          # Publish to marketplaces
├── catalog.yaml        # Lab catalog for store
├── licenses/           # License templates
└── templates/          # Export templates
```
