#!/bin/bash

# Log Analysis Script
# Usage: ./scripts/analyze-logs.sh [hours]
# Example: ./scripts/analyze-logs.sh 24

HOURS=${1:-1}  # Default to last 1 hour if not specified

echo "=== Analyzing Logs (Last $HOURS hours) ==="
echo ""

# Calculate time range
START_TIME=$(date -u -v-${HOURS}H '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date -u -d "$HOURS hours ago" '+%Y-%m-%dT%H:%M:%S')
END_TIME=$(date -u '+%Y-%m-%dT%H:%M:%S')

echo "Time Range: $START_TIME to $END_TIME"
echo ""

# Analyze ALB 5xx errors
echo "Checking ALB 5xx Errors..."
ERROR_COUNT=$(aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --dimensions Name=LoadBalancer,Value=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, 'devops-demo-dev')].LoadBalancerArn" --output text | cut -d: -f6-) \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 3600 \
  --statistics Sum \
  --query 'Datapoints[0].Sum' \
  --output text)

if [ "$ERROR_COUNT" != "None" ] && [ -n "$ERROR_COUNT" ]; then
  echo "⚠ 5xx Errors: $ERROR_COUNT"
else
  echo "✓ No 5xx errors"
fi

# Check RDS CPU
echo ""
echo "Checking RDS CPU Usage..."
RDS_ID=$(aws rds describe-db-instances \
  --query "DBInstances[?contains(DBInstanceIdentifier, 'devops-demo-dev')].DBInstanceIdentifier" \
  --output text)

if [ -n "$RDS_ID" ]; then
  AVG_CPU=$(aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name CPUUtilization \
    --dimensions Name=DBInstanceIdentifier,Value="$RDS_ID" \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --period 3600 \
    --statistics Average \
    --query 'Datapoints[0].Average' \
    --output text)
  
  if [ "$AVG_CPU" != "None" ] && [ -n "$AVG_CPU" ]; then
    echo "✓ Average CPU: ${AVG_CPU}%"
  else
    echo "✓ No data available"
  fi
fi

# Check ALB Response Time
echo ""
echo "Checking ALB Response Time..."
AVG_RESPONSE=$(aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, 'devops-demo-dev')].LoadBalancerArn" --output text | cut -d: -f6-) \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --period 3600 \
  --statistics Average \
  --query 'Datapoints[0].Average' \
  --output text)

if [ "$AVG_RESPONSE" != "None" ] && [ -n "$AVG_RESPONSE" ]; then
  echo "✓ Average Response Time: ${AVG_RESPONSE}s"
else
  echo "✓ No data available"
fi

echo ""
echo "=== Analysis Complete ==="
