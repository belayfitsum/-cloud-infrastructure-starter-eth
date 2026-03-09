#!/bin/bash

# Secret Rotation Script
# Usage: ./scripts/rotate-secrets.sh

set -e

echo "=== Secret Rotation ==="
echo ""

# Rotate database password
echo "Rotating database password..."
SECRET_ID="devops-demo-dev-db-password"

aws secretsmanager rotate-secret \
  --secret-id "$SECRET_ID" \
  --rotation-lambda-arn "arn:aws:lambda:eu-central-1:123456789:function:SecretsManagerRotation" 2>/dev/null || \
  echo "⚠ Automatic rotation not configured. Manual rotation required:"

echo ""
echo "Manual rotation steps:"
echo "1. Generate new password"
echo "2. Update RDS password"
echo "3. Update secret in Secrets Manager"
echo ""
echo "Commands:"
echo "  # Generate new password"
echo "  NEW_PASS=\$(openssl rand -base64 16)"
echo ""
echo "  # Update RDS"
echo "  aws rds modify-db-instance \\"
echo "    --db-instance-identifier devops-demo-dev-db \\"
echo "    --master-user-password \"\$NEW_PASS\" \\"
echo "    --apply-immediately"
echo ""
echo "  # Update Secrets Manager"
echo "  aws secretsmanager update-secret \\"
echo "    --secret-id $SECRET_ID \\"
echo "    --secret-string '{\"password\":\"\$NEW_PASS\"}'"

echo ""
echo "=== Rotation Complete ==="
