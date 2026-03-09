#!/bin/bash

# Health Check Script for DevOps Demo Infrastructure
# Usage: ./scripts/health-check.sh

#exit on error
set -e

echo "=== Infrastructure Health Check ==="
echo ""

# Check ALB
echo "Checking Application Load Balancer..."
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?contains(LoadBalancerName, 'devops-demo-dev')].LoadBalancerArn" \
  --output text)

if [ -n "$ALB_ARN" ]; then
  ALB_STATE=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns "$ALB_ARN" \
    --query "LoadBalancers[0].State.Code" \
    --output text)
  echo "✓ ALB Status: $ALB_STATE"
else
  echo "✗ ALB not found"
fi

# Check Target Health
echo ""
echo "Checking Target Group Health..."
TG_ARN=$(aws elbv2 describe-target-groups \
  --query "TargetGroups[?contains(TargetGroupName, 'devops-demo-dev')].TargetGroupArn" \
  --output text)

if [ -n "$TG_ARN" ]; then
  HEALTHY=$(aws elbv2 describe-target-health \
    --target-group-arn "$TG_ARN" \
    --query "length(TargetHealthDescriptions[?TargetHealth.State=='healthy'])" \
    --output text)
  TOTAL=$(aws elbv2 describe-target-health \
    --target-group-arn "$TG_ARN" \
    --query "length(TargetHealthDescriptions)" \
    --output text)
  echo "✓ Healthy Targets: $HEALTHY/$TOTAL"
else
  echo "✗ Target Group not found"
fi

# Check RDS
echo ""
echo "Checking RDS Database..."
RDS_STATUS=$(aws rds describe-db-instances \
  --query "DBInstances[?contains(DBInstanceIdentifier, 'devops-demo-dev')].DBInstanceStatus" \
  --output text)

if [ -n "$RDS_STATUS" ]; then
  echo "✓ RDS Status: $RDS_STATUS"
else
  echo "✗ RDS not found"
fi

# Check CloudWatch Alarms
echo ""
echo "Checking CloudWatch Alarms..."
ALARM_COUNT=$(aws cloudwatch describe-alarms \
  --query "length(MetricAlarms[?contains(AlarmName, 'devops-demo-dev')])" \
  --output text)
ALARM_STATE=$(aws cloudwatch describe-alarms \
  --query "MetricAlarms[?contains(AlarmName, 'devops-demo-dev')].StateValue" \
  --output text)

echo "✓ Total Alarms: $ALARM_COUNT"
echo "  Alarm States: $ALARM_STATE"

echo ""
echo "=== Health Check Complete ==="
