# Monitoring & Observability

## CloudWatch Alarms

### Response Time Alarm
- **Metric**: ALB TargetResponseTime
- **Threshold**: > 1 second
- **Evaluation**: 2 consecutive periods
- **Action**: Alarm state (add SNS for notifications)

### Unhealthy Hosts Alarm
- **Metric**: UnHealthyHostCount
- **Threshold**: > 0
- **Evaluation**: 1 period
- **Action**: Immediate alert

### RDS CPU Alarm
- **Metric**: RDS CPUUtilization
- **Threshold**: > 80%
- **Evaluation**: 2 consecutive periods (5 min each)
- **Action**: Investigate database performance

## Viewing Metrics

### AWS Console
1. Go to **CloudWatch** → **Alarms**
2. View alarm status and history
3. Click alarm to see metric graph

### CLI
```bash
# List alarms
aws cloudwatch describe-alarms

# Get alarm history
aws cloudwatch describe-alarm-history \
  --alarm-name devops-demo-dev-high-response-time
```

## Access Logs

### ALB Logs in S3
```bash
# List logs
aws s3 ls s3://devops-demo-dev-alb-logs-<account-id>/

# Download logs
aws s3 cp s3://devops-demo-dev-alb-logs-<account-id>/ ./logs/ --recursive
```

### Log Format
- Timestamp
- Client IP
- Request path
- Response code
- Response time
- Backend server

## Cost Monitoring

### Budget Alerts
- **Monthly budget**: $2 USD
- **Alert at 80%**: $1.60 spent
- **Alert at 100%**: $2.00 spent
- **Notification**: Email

### View Costs
```bash
# Current month costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## Dashboards

### Create Custom Dashboard
1. Go to **CloudWatch** → **Dashboards**
2. Create dashboard
3. Add widgets:
   - ALB request count
   - Response time graph
   - RDS CPU utilization
   - Unhealthy host count

## Metrics to Monitor

### Application Performance
- Response time
- Request count
- Error rate (5xx)
- Target health

### Infrastructure Health
- EC2 CPU utilization
- RDS CPU/memory
- Network throughput
- Disk usage

### Cost Metrics
- Daily spend
- Service-level costs
- Budget utilization

## Alerting Best Practices

- Set realistic thresholds
- Avoid alert fatigue
- Use evaluation periods to reduce false positives
- Add SNS topics for notifications
- Create runbooks for common alerts
