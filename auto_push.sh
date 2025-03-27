#!/bin/bash

# Function to check if there are uncommitted changes
check_for_changes() {
    # Check if there are any uncommitted changes (staged or unstaged)
    git diff --quiet || return 1  # Returns 1 if there are changes
    git diff --cached --quiet || return 1  # Check if there are staged changes
    return 0  # No changes
}

# Function to push code to a given repository
push_changes() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if we are on the main branch
    if [ "$branch" != "main" ]; then
        echo "You are on branch $branch, pushing to this branch..."
    else
        echo "You are on the main branch, pushing to main branch..."
    fi

    # Add and commit changes
    git add -A
    git commit -m "Auto-commit: $(date)"
    
    # Check for merge conflicts
    git pull --rebase origin "$branch" || {
        echo "Merge conflict occurred, aborting push."
        git rebase --abort
        return 1
    }
    
    # Push changes to remote repository
    git push origin "$branch"
    if [ $? -ne 0 ]; then
        echo "Push failed. Please resolve any issues."
        return 1
    fi
    return 0
}

# Function to push code to all connected repositories
push_all_repositories() {
    for remote in $(git remote); do
        echo "Pushing to remote repository: $remote"
        git push "$remote" || {
            echo "Failed to push to $remote."
        }
    done
}

# Main execution
if check_for_changes; then
    echo "No uncommitted changes found. Exiting..."
    exit 0
fi

echo "Uncommitted changes detected. Attempting to push..."

# Add changes to the staging area
git add -A

# Commit and push changes
if push_changes; then
    push_all_repositories
else
    echo "Aborted push due to conflict or failure."
fi
