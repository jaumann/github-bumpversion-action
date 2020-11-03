#!/bin/bash

# Configuration
default_semvar_bump=${DEFAULT_BUMP:-patch}
source=${SOURCE:-.}
dryrun=${DRY_RUN:-false}
new_version=${NEW_VERSION:-""}

cd "${GITHUB_WORKSPACE}/${source}" || return

# get latest tag that looks like a semver (with or without v)
git fetch --tags
tag=$(git for-each-ref --sort=-v:refname --count=1 --format '%(refname)' refs/tags/[0-9]*.[0-9]*.[0-9]* refs/tags/v[0-9]*.[0-9]*.[0-9]* | cut -d / -f 3-)

# get commit logs and determine home to bump the version
# supports #major, #minor, #patch (anything else will be 'minor')

# If we don't have any tags yet, check all of our commit history, otherwise check since the last tag
if [ -z "$tag" ]
then
  log=$(git log --pretty='%B')
else
  log=$(git log "$tag"..HEAD --pretty='%B')
  tag_commit=$(git rev-list -n 1 "$tag")
fi

# get current commit hash for tag
commit=$(git rev-parse HEAD)

if [ "$tag_commit" == "$commit" ]; then
  echo "No new commits since previous tag. Skipping..."
  echo ::set-output name=tag::"$tag"
  exit 0
fi

case "$log" in
  *#major* ) part="major";;
  *#minor* ) part="minor";;
  *#patch* ) part="patch";;
  * ) part="$default_semvar_bump";;
esac

# check if new version is already specified
if [ -z "$new_version" ]; then
  raw_output=$(bumpversion --list "$part" --dry-run)
else
  raw_output=$(bumpversion --list "$part" --dry-run --new-version="$new_version")
fi

old_version=$(echo "$raw_output" | grep -o 'current_version=\S*' | cut -d= -f2)
new_version=$(echo "$raw_output" | grep -o 'new_version=\S*' | cut -d= -f2)

# We should have all the information we need by this point
# Set Outputs and log information

echo "old_ver=$old_version" >> "$GITHUB_OUTPUT"
echo "new_ver=$new_version" >> "$GITHUB_OUTPUT"
echo "part=$part" >> "$GITHUB_OUTPUT"

echo "Semantic Version Part to Bump: $part"
echo "Current Version: $old_version"
echo "New Version: $new_version"

if [ "$dryrun" = true ]; then
  echo "Dryrun is set to true. Exiting..."
  exit 0
else
  git config --global user.email "bumpversion@github-actions"
  git config --global user.name "BumpVersion Action"
  bumpversion "$part" --new-version="$new_version" --verbose
fi
