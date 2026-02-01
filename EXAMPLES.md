# Git Remote Setup - Examples

This file contains example usage scenarios for the `setup-git-remote.sh` script.

## Example 1: Setting up a new repository with HTTPS

```bash
# Initialize a new Git repository
git init
git add .
git commit -m "Initial commit"

# Configure the remote and push to GitHub
./setup-git-remote.sh https://github.com/username/my-repo.git
```

## Example 2: Changing the remote URL of an existing repository

```bash
# Update the remote URL for an existing repository
./setup-git-remote.sh https://github.com/username/new-repo.git
```

## Example 3: Using SSH instead of HTTPS

```bash
# Configure remote with SSH URL
./setup-git-remote.sh git@github.com:username/my-repo.git
```

## Example 4: Ensuring your branch is named 'main'

The script automatically renames your current branch to 'main':

```bash
# If you're on a branch named 'master' or any other name
git branch
# * master

./setup-git-remote.sh https://github.com/username/my-repo.git
# The script will rename 'master' to 'main' and push
```

## What Happens When You Run the Script

1. **Remote Configuration**: The script checks if a remote named 'origin' exists
   - If it exists: Updates the URL
   - If it doesn't exist: Creates a new remote

2. **Branch Renaming**: Ensures your branch is named 'main'
   - Checks current branch name
   - Renames to 'main' if necessary

3. **Push to Remote**: Pushes your code and sets upstream
   - Uses `git push -u origin main`
   - Sets the upstream branch for future pushes/pulls

4. **Verification**: Displays remote configuration
   - Shows fetch and push URLs
   - Confirms the setup

## Expected Output

```
[INFO] Starting Git remote setup...

[INFO] Step 1: Configuring remote 'origin' with URL: https://github.com/username/my-repo.git
[WARNING] Remote 'origin' already exists. Updating URL...

[INFO] Step 2: Ensuring branch name is 'main'
[INFO] Already on 'main' branch

[INFO] Step 3: Pushing and setting upstream to origin/main
[INFO] Successfully pushed to origin/main

[INFO] Step 4: Verifying remote configuration
origin  https://github.com/username/my-repo.git (fetch)
origin  https://github.com/username/my-repo.git (push)

[INFO] Git remote setup completed successfully!
[INFO] Current branch: main
[INFO] Upstream: origin/main
```

## Troubleshooting

### Authentication Issues

If you encounter authentication issues:
- For HTTPS: Ensure you have a valid GitHub personal access token
- For SSH: Ensure your SSH key is configured correctly

### Permission Denied

If you get "Permission denied":
- Verify you have write access to the repository
- Check your Git credentials are correct

### Remote Already Exists

The script handles this automatically by updating the URL instead of failing.
