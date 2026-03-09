# CI/CD Pipeline

## Overview

Automated deployment pipeline using GitHub Actions and Terraform.

## Workflows

### 1. Terraform Plan (CI)
**File:** `.github/workflows/terraform-plan.yml`

**Trigger:** Pull Request to `main`

**Purpose:** Validate changes before merge

**Steps:**
1. Checkout code
2. Setup Terraform
3. Configure AWS credentials
4. Run `terraform fmt -check` (code formatting)
5. Run `terraform validate` (syntax check)
6. Run `terraform plan` (show changes)

**When it runs:**
```bash
git checkout -b feature/add-monitoring
# Make changes
git push origin feature/add-monitoring
# Create PR → Workflow runs automatically
```

### 2. Terraform Apply (CD - Dev)
**File:** `.github/workflows/terraform-apply.yml`

**Trigger:** Push to `main` (after PR merge)

**Purpose:** Deploy to dev environment

**Steps:**
1. Checkout code
2. Setup Terraform
3. Configure AWS credentials
4. Run `terraform init`
5. Run `terraform plan`
6. Run `terraform apply` (auto-approved)

**When it runs:**
```bash
# After PR is merged
# Automatically deploys to AWS
```

### 3. Terraform Production Deploy (CD - Prod)
**File:** `.github/workflows/terraform-prod.yml`

**Trigger:** Manual (workflow_dispatch)

**Purpose:** Deploy to production with confirmation

**Steps:**
1. Require typing "deploy" to confirm
2. Checkout code
3. Setup Terraform
4. Configure AWS credentials
5. Run `terraform plan -var="environment=prod"`
6. Run `terraform apply`

**When it runs:**
```bash
# Go to GitHub Actions tab
# Click "Terraform Production Deploy"
# Click "Run workflow"
# Type "deploy" to confirm
```

## Git Workflow

### Understanding pull_request vs push

**pull_request event:**
- Fires when PR is created or updated
- Code is NOT yet in main branch
- Used for validation only
- No deployment happens

**push event:**
- Fires when code is merged to main
- Code is now in main branch
- Used for deployment
- Actually creates/updates AWS resources

### Complete Flow

```
Day 1: Development
├─ Create branch: feature/add-alarms
├─ Make changes to terraform files
├─ Push to GitHub
└─ Create PR → terraform-plan.yml runs (validates)

Day 2: Review & Deploy
├─ Team reviews PR
├─ Approve and merge PR
└─ Merge → terraform-apply.yml runs (deploys to dev)

Day 3: Production (when ready)
├─ Go to GitHub Actions
├─ Run terraform-prod.yml manually
└─ Type "deploy" → Deploys to production
```

## Required GitHub Secrets

Set these in: **Settings → Secrets and variables → Actions**

```
AWS_ACCESS_KEY_ID       # AWS access key
AWS_SECRET_ACCESS_KEY   # AWS secret key
```

## Best Practices

### Branch Protection
Enable in: **Settings → Branches → Add rule**
- Require PR before merging
- Require status checks (terraform-plan must pass)
- Require approvals (1-2 reviewers)

### Deployment Safety
- Dev: Auto-deploys on merge (fast iteration)
- Prod: Manual trigger only (safety)
- Always review plan output before apply

### Rollback Strategy
```bash
# If deployment fails, revert the merge
git revert <commit-hash>
git push origin main
# terraform-apply.yml runs and reverts changes
```

## Troubleshooting

### Workflow fails on terraform init
- Check AWS credentials in GitHub Secrets
- Verify IAM permissions

### Workflow fails on terraform plan
- Check Terraform syntax locally first
- Run `terraform fmt` before committing

### Workflow fails on terraform apply
- Check AWS service quotas
- Verify resource names are unique
- Check CloudWatch logs for details
