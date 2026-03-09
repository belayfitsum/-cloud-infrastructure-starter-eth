# Deployment Guide

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.5
- AWS account with appropriate permissions

## Initial Setup

### 1. Configure AWS CLI
```bash
aws configure
```

### 2. Initialize Terraform
```bash
cd terraform
terraform init
```

## Deploy Infrastructure

### 1. Review Plan
```bash
terraform plan
```

### 2. Apply Changes
```bash
terraform apply
```

### 3. Get Outputs
```bash
terraform output alb_dns_name
terraform output rds_endpoint
terraform output secret_arn
```

## Access Application

Visit the ALB DNS name:
```bash
curl http://$(terraform output -raw alb_dns_name)
```

## Retrieve Database Credentials

```bash
aws secretsmanager get-secret-value \
  --secret-id devops-demo-dev-db-password \
  --query SecretString \
  --output text | jq .
```

## Connect to EC2 Instances

Using SSM (no SSH keys needed):
```bash
# List instances
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-demo-dev-web-*" \
  --query "Reservations[].Instances[].InstanceId"

# Connect
aws ssm start-session --target <instance-id>
```

## Update Infrastructure

```bash
# Modify .tf files
terraform plan
terraform apply
```

## Destroy Infrastructure

```bash
terraform destroy
```

## Troubleshooting

### Plan fails
- Check AWS credentials
- Verify region in variables.tf

### Apply fails
- Check AWS service quotas
- Verify IAM permissions

### Can't access application
- Check security groups
- Verify ALB target health
- Check EC2 instance status
