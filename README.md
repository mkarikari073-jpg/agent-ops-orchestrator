# agent-ops-orchestrator
AI agents working together to execute complex, end to end business 

## Git Remote Setup

This repository includes a utility script to configure Git remotes and ensure proper branch setup.

### Usage

The `setup-git-remote.sh` script automates the following operations:
1. Add or update the remote repository
2. Ensure the branch name is 'main'
3. Push and set upstream to main
4. Verify the remote configuration

### Running the Script

```bash
./setup-git-remote.sh <repository-url>
```

**Example:**
```bash
./setup-git-remote.sh https://github.com/username/repo.git
```

or with SSH:
```bash
./setup-git-remote.sh git@github.com:username/repo.git
```

### What the Script Does

The script performs the following steps:

1. **Add or Update Remote:** Checks if a remote named 'origin' exists. If it does, updates its URL; otherwise, creates a new remote.
   ```bash
   git remote add origin <repo-url> || git remote set-url origin <repo-url>
   ```

2. **Ensure Branch is Main:** Renames the current branch to 'main' if it has a different name.
   ```bash
   git branch -M main
   ```

3. **Push and Set Upstream:** Pushes the main branch to the remote and sets it as the upstream branch.
   ```bash
   git push -u origin main
   ```

4. **Verify Configuration:** Displays the configured remotes to confirm the setup.
   ```bash
   git remote -v
   ```

### Requirements

- Git installed on your system
- Appropriate permissions to push to the target repository
- Valid repository URL (HTTPS or SSH)

