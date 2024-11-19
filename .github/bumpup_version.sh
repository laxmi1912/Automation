#!/bin/bash

# Check if the required input (major, minor, patch) is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <major|minor|patch>"
  exit 1
fi

# Get the current Git tag
CURRENT_TAG=$(git describe --tags --abbrev=0)
if [ -z "$CURRENT_TAG" ]; then
  echo "No tags found, starting from version 0.0.0."
  CURRENT_TAG="0.0.0"
fi

# Split the version into its components (MAJOR.MINOR.PATCH)
IFS='.' read -r -a VERSION_ARRAY <<< "$CURRENT_TAG"
MAJOR=${VERSION_ARRAY[0]}
MINOR=${VERSION_ARRAY[1]}
PATCH=${VERSION_ARRAY[2]}

# Increment the version based on the input argument
case $1 in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Invalid argument. Please use 'major', 'minor', or 'patch'."
    exit 1
    ;;
esac

# Construct the new version
NEW_TAG="${MAJOR}.${MINOR}.${PATCH}"

# Create a new Git tag
echo "Creating new tag: $NEW_TAG"
git tag "$NEW_TAG"

# Push the new tag to the remote repository
git push origin "$NEW_TAG"

echo "Tag $NEW_TAG successfully created and pushed."
