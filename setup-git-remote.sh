#!/bin/bash

# Git Remote Setup Script
# This script configures Git remote repository and ensures proper branch setup

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 <repository-url>

This script will:
  1. Add or update the remote repository
  2. Ensure the branch name is 'main'
  3. Push and set upstream to main
  4. Verify the remote configuration

Arguments:
  repository-url    The URL of the remote Git repository

Example:
  $0 https://github.com/username/repo.git
  $0 git@github.com:username/repo.git

EOF
    exit 1
}

# Check if repository URL is provided
if [ $# -eq 0 ]; then
    print_error "Repository URL is required"
    usage
fi

REPO_URL="$1"

# Validate repository URL format
if [[ ! "$REPO_URL" =~ ^(https?://|git@) ]]; then
    print_error "Invalid repository URL format. Must start with https://, http://, or git@"
    exit 1
fi

print_info "Starting Git remote setup..."
echo ""

# Step 1: Add or update remote
print_info "Step 1: Configuring remote 'origin' with URL: $REPO_URL"
if git remote get-url origin >/dev/null 2>&1; then
    print_warning "Remote 'origin' already exists. Updating URL..."
    git remote set-url origin "$REPO_URL"
else
    print_info "Adding new remote 'origin'..."
    git remote add origin "$REPO_URL"
fi
echo ""

# Step 2: Ensure branch name is main
print_info "Step 2: Ensuring branch name is 'main'"
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    print_warning "Current branch is '$CURRENT_BRANCH'. Renaming to 'main'..."
    git branch -M main
else
    print_info "Already on 'main' branch"
fi
echo ""

# Step 3: Push and set upstream
print_info "Step 3: Pushing and setting upstream to origin/main"
if git push -u origin main; then
    print_info "Successfully pushed to origin/main"
else
    print_error "Failed to push to origin/main"
    print_warning "This may be due to authentication issues or network problems"
    exit 1
fi
echo ""

# Step 4: Verify
print_info "Step 4: Verifying remote configuration"
git remote -v
echo ""

print_info "Git remote setup completed successfully!"
print_info "Current branch: $(git branch --show-current)"
print_info "Upstream: $(git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo 'Not set')"
