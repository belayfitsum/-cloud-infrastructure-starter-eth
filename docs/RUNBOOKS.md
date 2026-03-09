# Operational Runbooks

## Overview

Step-by-step procedures for common operational tasks and incident response.

---

## Runbook 1: Application Down / 5xx Errors

### Symptoms
- Users report application unavailable
- CloudWatch alarm: High 5xx errors
- Health check script shows unhealthy targets

### Investigation Steps

1. **Check target health**
   ```bash
   ./scripts/health-check.sh
   ```

2. **Check recent deployments**
   ```bash
   git log --oneline -5
   # Check GitHub Actions for recent runs
   ```

3. **Check EC2 instance status**
   ```bash
   aws ec2 describe-instances \
     --filters "Name=tag:Name,Values=devops-demo-dev-web-*" \
     --query "Reservations[].Instances[].[InstanceId,State.Name]"
   ```

4. **Check application logs** (if CloudWatch Agent installed)
   ```bash
   aws logs tail /aws/ec2/devops-demo-dev --follow
   ```

### Resolution Steps

**If EC2 instances are stopped:**
```bash
aws ec2 start-instances --instance-ids <instance-id>
```

**If instances are running but unhealthy:**
```bash
# Connect via SSM
aws ssm start-session --target <instance-id>

# Check Apache status
sudo systemctl status httpd

# Restart Apache
sudo systemctl restart httpd
```

**If recent deployment caused issue:**
```bash
# Revert the deployment
git revert <commit-hash>
git push origin main
# Wait for GitHub Actions to redeploy
```

### Prevention
- Enable Auto Scaling (future enhancement)
- Add application-level health checks
- Implement blue-green deployments

---

## Runbook 2: High RDS CPU Usage

### Symptoms
- CloudWatch alarm: RDS CPU > 80%
- Application slow response times
- Database connection timeouts

### Investigation Steps

1. **Check current CPU usage**
   ```bash
   ./scripts/analyze-logs.sh 1
   ```

2. **Check active connections**
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier devops-demo-dev-db \
     --query "DBInstances[0].DBInstanceStatus"
   ```

3. **Review slow query logs** (if enabled)
   ```bash
   aws rds describe-db-log-files \
     --db-instance-identifier devops-demo-dev-db
   ```

### Resolution Steps

**Immediate (Short-term):**
```bash
# Scale up RDS instance
aws rds modify-db-instance \
  --db-instance-identifier devops-demo-dev-db \
  --db-instance-class db.t3.small \
  --apply-immediately
```

**Long-term:**
- Optimize slow queries
- Add database indexes
- Implement caching (Redis/ElastiCache)
- Enable RDS Performance Insights

### Prevention
- Set up query performance monitoring
- Regular database maintenance
- Implement connection pooling

---

## Runbook 3: High AWS Costs

### Symptoms
- Budget alert triggered
- Unexpected charges
- Cost spike in Cost Explorer

### Investigation Steps

1. **Check current spend**
   ```bash
   aws ce get-cost-and-usage \
     --time-period Start=$(date -v-7d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
     --granularity DAILY \
     --metrics BlendedCost
   ```

2. **Identify top services**
   ```bash
   aws ce get-cost-and-usage \
     --time-period Start=$(date -v-7d +%Y-%m-%d),End=$(date +%Y-%m-%d) \
     --granularity DAILY \
     --metrics BlendedCost \
     --group-by Type=DIMENSION,Key=SERVICE
   ```

3. **Check for unused resources**
   ```bash
   # Unattached EBS volumes
   aws ec2 describe-volumes \
     --filters "Name=status,Values=available"
   
   # Stopped instances (still incur EBS costs)
   aws ec2 describe-instances \
     --filters "Name=instance-state-name,Values=stopped"
   ```

### Resolution Steps

**Immediate:**
- Stop non-production environments
- Delete unused resources
- Reduce RDS/EC2 instance sizes

**Long-term:**
- Implement auto-shutdown for dev environments
- Use Reserved Instances for production
- Enable S3 lifecycle policies
- Set up Cost Anomaly Detection

---

## Runbook 4: Security Incident

### Symptoms
- Unusual API calls in CloudTrail
- Unexpected resource creation
- Security group changes
- GuardDuty findings

### Investigation Steps

1. **Check recent IAM activity**
   ```bash
   aws cloudtrail lookup-events \
     --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser \
     --max-results 10
   ```

2. **Review security group changes**
   ```bash
   aws ec2 describe-security-groups \
     --filters "Name=tag:Name,Values=*devops-demo*"
   ```

3. **Check for public S3 buckets**
   ```bash
   aws s3api list-buckets --query "Buckets[].Name" | \
     xargs -I {} aws s3api get-bucket-acl --bucket {}
   ```

### Resolution Steps

**Immediate:**
```bash
# Rotate compromised credentials
aws secretsmanager rotate-secret \
  --secret-id devops-demo-dev-db-password

# Revoke suspicious IAM sessions
aws iam delete-access-key \
  --access-key-id <suspicious-key-id> \
  --user-name <user-name>

# Lock down security groups
aws ec2 revoke-security-group-ingress \
  --group-id <sg-id> \
  --ip-permissions <suspicious-rule>
```

**Post-Incident:**
- Enable MFA on all accounts
- Review IAM policies
- Enable CloudTrail logging
- Conduct security audit

---

## Runbook 5: Failed Terraform Deployment

### Symptoms
- GitHub Actions workflow fails
- Terraform apply errors
- Resources in inconsistent state

### Investigation Steps

1. **Check workflow logs**
   - Go to GitHub Actions tab
   - Review failed workflow run
   - Check error messages

2. **Check Terraform state**
   ```bash
   cd terraform
   terraform show
   ```

3. **Validate configuration**
   ```bash
   terraform validate
   terraform plan
   ```

### Resolution Steps

**If state is corrupted:**
```bash
# Import existing resource
terraform import aws_instance.web <instance-id>

# Or refresh state
terraform refresh
```

**If resource conflict:**
```bash
# Remove from state (careful!)
terraform state rm aws_instance.web

# Then re-import
terraform import aws_instance.web <instance-id>
```

**If syntax error:**
```bash
# Fix the code
terraform fmt
terraform validate
# Commit and push
```

### Prevention
- Always run `terraform plan` before apply
- Use S3 backend with state locking
- Enable branch protection
- Require PR reviews

---

## Emergency Contacts

- **On-Call Engineer**: [Your contact]
- **AWS Support**: [Support plan details]
- **Team Lead**: [Contact]

## Escalation Path

1. On-call engineer (15 minutes)
2. Team lead (30 minutes)
3. AWS Support (if infrastructure issue)
