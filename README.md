# DevOps- AWS Infrastructure Project

AWS infrastructure demonstrating DevOps/SRE best practices with Terraform, CI/CD, and comprehensive monitoring.

## Features

- ✅ **Infrastructure as Code**: Terraform with modular design
- ✅ **CI/CD Pipeline**: GitHub Actions with automated deployments
- ✅ **High Availability**: Multi-AZ deployment across 2 availability zones
- ✅ **Security**: Secrets Manager, IAM roles, security groups, SSM access
- ✅ **Monitoring**: CloudWatch alarms, metrics, and logging
- ✅ **Cost Management**: Budget alerts and resource optimization
- ✅ **Automation**: Health checks, log analysis, resource cleanup scripts
- ✅ **Incident Management**: Comprehensive runbooks and procedures

## Quick Start

```bash
# Initialize Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Access application
terraform output alb_dns_name

# Run health check
./scripts/health-check.sh

# Analyze logs
./scripts/analyze-logs.sh 24
```

## Documentation

### Core Documentation
- [Architecture](docs/ARCHITECTURE.md) - System design and components
- [Deployment](docs/DEPLOYMENT.md) - Deployment guide
- [Security](docs/SECURITY.md) - Security best practices
- [Monitoring](docs/MONITORING.md) - Observability setup

### Operations
- [CI/CD Pipeline](docs/CICD.md) - GitHub Actions workflows
- [Runbooks](docs/RUNBOOKS.md) - Incident response procedures
- [TODO](TODO.md) - Future enhancements

## Infrastructure Components

### Networking
- VPC with public and private subnets (Multi-AZ)
- Internet Gateway
- Route tables and associations

### Compute
- 2x EC2 instances (t3.micro) in private subnets
- Application Load Balancer in public subnets
- IAM roles with least privilege
- SSM Session Manager access (no SSH keys)

### Database
- RDS MySQL 8.0 (db.t3.micro)
- Private subnet placement
- Automated backups
- Credentials in Secrets Manager

### Security
- AWS Secrets Manager for credential management
- Security groups with minimal access
- IAM instance profiles
- Encrypted S3 buckets

### Monitoring & Observability
- CloudWatch alarms (response time, health, CPU)
- ALB access logs to S3
- Log retention policies
- Health check automation

### Cost Management
- Monthly budget alerts (80% and 100%)
- Resource cleanup automation
- S3 lifecycle policies

## CI/CD Pipeline

### Workflows
1. **terraform-plan.yml** - Validates on Pull Requests
2. **terraform-apply.yml** - Auto-deploys to dev on merge
3. **terraform-prod.yml** - Manual production deployment

### Git Flow
```
Feature Branch → PR → terraform-plan runs → Review → Merge → terraform-apply runs → Deploy
```

## Automation Scripts

```bash
# Health check
./scripts/health-check.sh

# Log analysis (last 24 hours)
./scripts/analyze-logs.sh 24

# Resource cleanup (dry run)
./scripts/cleanup-resources.sh --dry-run

# Secret rotation
./scripts/rotate-secrets.sh
```

## Tech Stack

- **IaC**: Terraform 1.5+
- **Cloud**: AWS (VPC, EC2, RDS, ALB, CloudWatch, Secrets Manager)
- **CI/CD**: GitHub Actions
- **OS**: Amazon Linux 2
- **Scripting**: Bash

## Project Structure

```
.
├── .github/workflows/     # CI/CD pipelines
├── terraform/             # Infrastructure code
├── scripts/               # Automation scripts
├── docs/                  # Documentation
└── README.md
```

## Skills Demonstrated

- Infrastructure as Code (Terraform)
- CI/CD pipeline design and implementation
- Cloud architecture (AWS)
- Security hardening and secret management
- Monitoring and observability
- Incident management and runbooks
- Automation and scripting
- Cost optimization
- Documentation and knowledge sharing
