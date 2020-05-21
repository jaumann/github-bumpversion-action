#!/bin/bash

# Configuration
default_semvar_bump=${DEFAULT_BUMP:-minor}
source=${SOURCE:-.}
dryrun=${DRY_RUN:-false}

cd ${GITHUB_WORKSPACE}/${source}

# get latest tag that looks like a semver (with or without v)
git fetch --tags
tag=$(git for-each-ref --sort=-v:refname --count=1 --format '%(refname)' refs/tags/[0-9]*.[0-9]*.[0-9]* refs/tags/v[0-9]*.[0-9]*.[0-9]* | cut -d / -f 3-)
tag_commit=$(git rev-list -n 1 $tag)

# get current commit hash for tag
commit=$(git rev-parse HEAD)

if [ "$tag_commit" == "$commit" ]; then
  echo "No new commits since previous tag. Skipping..."
  echo ::set-output name=tag::$tag
  exit 0
fi


# get commit logs and determine home to bump the version
# supports #major, #minor, #patch (anything else will be 'minor')

# If we don't have any tags yet, check all of our commit history, otherwise check since the last tag
if [ -z "$tag" ]
then
  log=$(git log --pretty='%B')
else
  log=$(git log $tag..HEAD --pretty='%B')
fi

case "$log" in
  *#major* ) part="major";;
  *#minor* ) part="minor";;
  *#patch* ) part="patch";;
  * ) part=$default_semvar_bump;;
esac

raw_output=$(bumpversion --list $part --dry-run --allow-dirty)
old_version=$(echo $raw_output | grep -o 'current_version=\S*' | cut -d= -f2)
new_version=$(echo $raw_output | grep -o 'new_version=\S*' | cut -d= -f2)

# We should have all the information we need by this point
# Set Outputs and log information

echo ::set-output name=old_ver::$old_version
echo ::set-output name=new_ver::$new_version
echo ::set-output name=part::$part

echo "Semantic Version Part to Bump: $part"
echo "Current Version: $old_version"
echo "New Version: $new_version"
