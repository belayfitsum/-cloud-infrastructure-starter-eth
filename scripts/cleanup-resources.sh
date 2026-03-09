#!/bin/bash

# Resource Cleanup Script
# Usage: ./scripts/cleanup-resources.sh [--dry-run]

DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
  echo "=== DRY RUN MODE - No changes will be made ==="
fi

echo "=== AWS Resource Cleanup ==="
echo ""

# Find unattached EBS volumes
echo "Checking for unattached EBS volumes..."
VOLUMES=$(aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query "Volumes[].VolumeId" \
  --output text)

if [ -n "$VOLUMES" ]; then
  echo "Found unattached volumes: $VOLUMES"
  if [ "$DRY_RUN" = false ]; then
    for vol in $VOLUMES; do
      echo "Deleting volume: $vol"
      aws ec2 delete-volume --volume-id "$vol"
    done
  fi
else
  echo "✓ No unattached volumes"
fi

# Find old snapshots (older than 30 days)
echo ""
echo "Checking for old snapshots..."
CUTOFF_DATE=$(date -u -v-30d '+%Y-%m-%d' 2>/dev/null || date -u -d "30 days ago" '+%Y-%m-%d')
OLD_SNAPSHOTS=$(aws ec2 describe-snapshots \
  --owner-ids self \
  --query "Snapshots[?StartTime<'$CUTOFF_DATE'].SnapshotId" \
  --output text)

if [ -n "$OLD_SNAPSHOTS" ]; then
  echo "Found old snapshots: $OLD_SNAPSHOTS"
  if [ "$DRY_RUN" = false ]; then
    for snap in $OLD_SNAPSHOTS; do
      echo "Deleting snapshot: $snap"
      aws ec2 delete-snapshot --snapshot-id "$snap"
    done
  fi
else
  echo "✓ No old snapshots"
fi

# Find unused Elastic IPs
echo ""
echo "Checking for unused Elastic IPs..."
UNUSED_EIP=$(aws ec2 describe-addresses \
  --query "Addresses[?AssociationId==null].AllocationId" \
  --output text)

if [ -n "$UNUSED_EIP" ]; then
  echo "⚠ Found unused Elastic IPs: $UNUSED_EIP"
  echo "  (Not auto-deleting - review manually)"
else
  echo "✓ No unused Elastic IPs"
fi

echo ""
if [ "$DRY_RUN" = true ]; then
  echo "=== Dry run complete - run without --dry-run to apply changes ==="
else
  echo "=== Cleanup Complete ==="
fi
