# Infrastructure Architecture

## Overview

Multi-tier AWS infrastructure with high availability, security, and observability.

## Network Architecture

### VPC Design
- **CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24 (2 AZs)
- **Private Subnets**: 10.0.10.0/24, 10.0.11.0/24 (2 AZs)
- **Internet Gateway**: Public internet access

### Traffic Flow
```
Internet → ALB (public) → EC2 (private) → RDS (private)
```

## Components

### Compute Layer
- **EC2 Instances**: 2x t3.micro in private subnets
- **OS**: Amazon Linux 2
- **Web Server**: Apache HTTP Server
- **Access**: SSM Session Manager (no SSH)

### Load Balancing
- **Type**: Application Load Balancer
- **Placement**: Public subnets
- **Health Checks**: HTTP on / every 30s
- **Logging**: Access logs to S3

### Database Layer
- **Engine**: MySQL 8.0
- **Instance**: db.t3.micro
- **Storage**: 20GB gp3
- **Placement**: Private subnets
- **Backup**: Automated snapshots

### Security
- **Secrets**: AWS Secrets Manager
- **IAM**: Roles with least privilege
- **Security Groups**: 
  - ALB: 80, 443 from internet
  - EC2: 80 from ALB only
  - RDS: 3306 from EC2 only

### Monitoring
- **Metrics**: CloudWatch metrics for all resources
- **Alarms**: Response time, health, CPU
- **Logs**: ALB access logs (30-day retention)
- **Cost**: Budget alerts at 80% and 100%

## High Availability

- Multi-AZ deployment
- 2 EC2 instances across AZs
- ALB distributes traffic
- RDS in private subnets

## Security Best Practices

- No public access to databases
- Secrets in Secrets Manager
- IAM roles (no access keys)
- Security groups with minimal access
- Private subnets for backend
