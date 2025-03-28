#!/bin/bash

# Function to check if there are uncommitted changes in a repository
check_for_changes() {
    git diff --quiet || return 1  # Returns 1 if there are unstaged changes
    git diff --cached --quiet || return 1  # Returns 1 if there are staged changes
    return 0  # No changes
}

# Function to handle merge conflict
handle_merge_conflict() {
    echo "Merge conflict occurred, resolving it manually..."
    # You can either resolve manually or automate the conflict resolution here
    return 1
}

# Function to check if local branch is up to date with remote
check_if_up_to_date_with_remote() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Fetch the latest updates from the remote repository
    git fetch origin "$branch"
    
    # Compare local and remote branches
    local local_commit=$(git rev-parse "$branch")
    local remote_commit=$(git rev-parse "origin/$branch")
    
    if [ "$local_commit" != "$remote_commit" ]; then
        echo "Local branch is not up to date with the remote branch. Please pull or merge changes first."
        return 1
    fi
    
    return 0
}

# Function to push code to the given repository
push_changes() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if we are on main branch
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
        handle_merge_conflict
        git rebase --abort
        return 1
    }
    
    # Check if local branch is up to date with remote
    if ! check_if_up_to_date_with_remote; then
        echo "Aborting push as local branch is not up to date with remote."
        return 1
    fi
    
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
# Find all directories containing a .git folder and iterate over them
for dir in $(find /home/ashmit -type d -name ".git" -exec dirname {} \;); do
    echo "Found git repo in directory: $dir"
    cd "$dir" || continue

    # Add directory to safe directory list (fix dubious ownership issue)
    git config --global --add safe.directory "$dir"

    # Check for uncommitted changes
    if check_for_changes; then
        echo "No uncommitted changes in $dir. Skipping..."
        continue
    fi

    echo "Uncommitted changes detected in $dir. Attempting to push..."

    # Add changes to the staging area
    git add -A

    # Commit and push changes
    if push_changes; then
        push_all_repositories
    else
        echo "Aborted push due to conflict or failure in $dir."
    fi
done
