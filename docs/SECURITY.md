# Security Best Practices

## Implemented Security Controls

### Secret Management
- **AWS Secrets Manager**: Database credentials stored encrypted
- **No hardcoded secrets**: All sensitive data in Secrets Manager
- **Automatic rotation**: Ready for secret rotation setup
- **IAM access control**: EC2 instances have read-only access

### Network Security
- **Private subnets**: Database and app servers not publicly accessible
- **Security groups**: Least privilege network access
  - ALB: Only 80/443 from internet
  - EC2: Only 80 from ALB
  - RDS: Only 3306 from EC2
- **No SSH**: SSM Session Manager for secure access

### IAM Security
- **IAM roles**: EC2 uses roles, not access keys
- **Least privilege**: Minimal permissions per resource
- **Instance profiles**: Temporary credentials auto-rotated
- **No root access**: Service-specific IAM roles

### Data Security
- **Encryption at rest**: RDS storage encrypted
- **Encryption in transit**: HTTPS ready (add certificate)
- **S3 encryption**: ALB logs encrypted (AES256)
- **Private buckets**: All S3 buckets block public access

### Monitoring & Compliance
- **CloudWatch alarms**: Alert on security events
- **Access logs**: ALB logs all requests
- **Audit trail**: CloudTrail for API calls (add separately)
- **Cost alerts**: Budget monitoring

## Security Hardening Checklist

### Completed
- ✅ Secrets in Secrets Manager
- ✅ Private subnets for backend
- ✅ Security groups with minimal access
- ✅ IAM roles instead of keys
- ✅ SSM access (no SSH keys)
- ✅ S3 bucket encryption
- ✅ RDS in private subnet

### Recommended Next Steps
- [ ] Enable AWS CloudTrail
- [ ] Add WAF to ALB
- [ ] Enable GuardDuty
- [ ] Add SSL/TLS certificate
- [ ] Enable RDS encryption
- [ ] Implement secret rotation
- [ ] Add VPC Flow Logs
- [ ] Enable AWS Config

## Incident Response

### Access Logs
```bash
# Download ALB logs
aws s3 sync s3://devops-demo-dev-alb-logs-<account-id> ./logs/
```

### Check Security Groups
```bash
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*devops-demo*"
```

### Rotate Secrets
```bash
aws secretsmanager rotate-secret \
  --secret-id devops-demo-dev-db-password
```
