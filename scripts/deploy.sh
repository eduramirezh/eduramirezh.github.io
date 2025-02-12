#!/bin/bash

# Exit on error
set -e

# Get the current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Ensure working directory is clean
if [[ -n $(git status -s) ]]; then
    echo "Error: Working directory is not clean. Please commit or stash changes first."
    exit 1
fi

# Build the site
echo "Building site..."
JEKYLL_ENV=production bundle exec jekyll build

# Switch to gh-pages branch, creating it if it doesn't exist
if git show-ref --verify --quiet refs/heads/gh-pages; then
    git checkout gh-pages
    # Remove existing files
    git rm -rf .
else
    git checkout --orphan gh-pages
    git rm -rf .
fi

# Copy _site contents to root
echo "Copying built site..."
cp -r _site/* .
rm -rf _site

# Create .nojekyll file
touch .nojekyll

# Add all files
git add .

# Commit
echo "Committing changes..."
git commit -m "Deploy site update $(date '+%Y-%m-%d %H:%M:%S')"

# Push to gh-pages
echo "Pushing to gh-pages branch..."
git push origin gh-pages

# Switch back to original branch
echo "Switching back to $current_branch branch..."
git checkout $current_branch

echo "Deployment complete!"