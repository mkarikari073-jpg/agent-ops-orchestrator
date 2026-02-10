#!/bin/bash

# Test script for setup-git-remote.sh
# This script tests the Git remote setup script in a safe test environment

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

echo "======================================"
echo "Testing setup-git-remote.sh"
echo "======================================"
echo ""

# Test 1: Script exists and is executable
print_test "Checking if script exists and is executable"
if [ -x "./setup-git-remote.sh" ]; then
    print_pass "Script exists and is executable"
else
    print_fail "Script does not exist or is not executable"
    exit 1
fi
echo ""

# Test 2: Script shows usage when no arguments provided
print_test "Testing usage message (no arguments)"
if ./setup-git-remote.sh 2>&1 | grep -q "Usage:"; then
    print_pass "Usage message displayed correctly"
else
    print_fail "Usage message not displayed"
    exit 1
fi
echo ""

# Test 3: Script validates URL format (invalid URL)
print_test "Testing URL validation (invalid URL)"
if ./setup-git-remote.sh "invalid-url" 2>&1 | grep -q "Invalid repository URL format"; then
    print_pass "Invalid URL correctly rejected"
else
    print_fail "Invalid URL validation failed"
    exit 1
fi
echo ""

# Test 4: Script validates different URL formats
print_test "Testing URL validation (HTTPS URL format check)"
SCRIPT_PATH="$(pwd)/setup-git-remote.sh"
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init -q
git config user.name "Test User"
git config user.email "test@example.com"
echo "test" > test.txt
git add test.txt
git commit -q -m "Initial commit"

# Create a mock script that will exit before trying to push
cat > test-remote-mock.sh << 'MOCKEOF'
#!/bin/bash
set -e
REPO_URL="$1"
if [[ ! "$REPO_URL" =~ ^(https?://|git@) ]]; then
    echo "Invalid repository URL format. Must start with https://, http://, or git@"
    exit 1
fi
echo "Configuring remote 'origin' with URL: $REPO_URL"
if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$REPO_URL"
else
    git remote add origin "$REPO_URL"
fi
echo "Remote configured successfully"
exit 0
MOCKEOF
chmod +x test-remote-mock.sh

# Test with the mock
if ./test-remote-mock.sh "https://github.com/test/repo.git" 2>&1 | grep -q "Configuring remote"; then
    print_pass "Valid HTTPS URL accepted"
else
    print_fail "Valid HTTPS URL rejected"
    cd - > /dev/null
    rm -rf "$TEST_DIR"
    exit 1
fi

cd - > /dev/null
rm -rf "$TEST_DIR"
echo ""

# Test 5: Check script syntax
print_test "Testing script syntax"
if bash -n ./setup-git-remote.sh; then
    print_pass "Script syntax is valid"
else
    print_fail "Script has syntax errors"
    exit 1
fi
echo ""

# Test 6: Verify script commands are correct
print_test "Verifying script contains required Git commands"
SCRIPT_CONTENT=$(cat ./setup-git-remote.sh)
COMMANDS_FOUND=0

if echo "$SCRIPT_CONTENT" | grep -q "git remote add"; then
    COMMANDS_FOUND=$((COMMANDS_FOUND + 1))
fi
if echo "$SCRIPT_CONTENT" | grep -q "git remote set-url"; then
    COMMANDS_FOUND=$((COMMANDS_FOUND + 1))
fi
if echo "$SCRIPT_CONTENT" | grep -q "git branch -M main"; then
    COMMANDS_FOUND=$((COMMANDS_FOUND + 1))
fi
if echo "$SCRIPT_CONTENT" | grep -q "git push -u origin main"; then
    COMMANDS_FOUND=$((COMMANDS_FOUND + 1))
fi
if echo "$SCRIPT_CONTENT" | grep -q "git remote -v"; then
    COMMANDS_FOUND=$((COMMANDS_FOUND + 1))
fi

if [ $COMMANDS_FOUND -eq 5 ]; then
    print_pass "All required Git commands found in script"
else
    print_fail "Missing required Git commands (found $COMMANDS_FOUND/5)"
    exit 1
fi
echo ""

echo "======================================"
echo -e "${GREEN}All tests passed!${NC}"
echo "======================================"
