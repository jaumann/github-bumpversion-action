# github-bumpversion-action

A Github Action to use the [bumpversion](https://pypi.org/project/bumpversion/) application to bump and tag branches

![Lint Status](https://github.com/jaumann/github-bumpversion-action/workflows/Lint%20Code%20Base/badge.svg)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/jaumann/github-bumpversion-action?label=Github%20Release)](https://github.com/jaumann/github-bumpversion-action/releases)
[![Docker Image Version (tag latest semver)](https://img.shields.io/docker/v/jaumann/github-bumpversion-action?sort=semver&label=Docker%20Version)](https://hub.docker.com/r/jaumann/github-bumpversion-action)
[![License](https://img.shields.io/github/license/jaumann/github-bumpversion-action)](LICENSE)

## Usage

```Dockerfile
name: Bump version
on:
  push:
    branches:
      - master
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Bump version and push tag
        uses: jaumann/github-bumpversion-action@v0.0.6
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: Push changes
        uses: ad-m/github-push-action@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          tags: true
```

### Options

**Environment Variables**

* **GITHUB_TOKEN** ***(required)*** - Required for permission to tag the repo.
* **DEFAULT_BUMP** *(optional)* - Which type of bump to use when none explicitly provided (default: `minor`).
* **SOURCE** *(optional)* - Operate on a relative path under $GITHUB_WORKSPACE.
* **DRY_RUN** *(optional)* - Determine the next version without tagging the branch. The workflow can use the outputs `new_tag` and `tag` in subsequent steps. Possible values are ```true``` and ```false``` (default).
* **NEW_VERSION** *(optional)* - New version that should be in the files.


### Outputs

* **new_tag** - The value of the newly created tag.
* **old_tag** - The value of the previous tag.
* **part** - The part of version which was bumped.

> ***Note:*** This action creates a [lightweight tag](https://developer.github.com/v3/git/refs/#create-a-reference).

### Bumping

**Manual Bumping:** Any commit message that includes `#major`, `#minor`, or `#patch` will trigger the respective version bump. If two or more are present, the highest-ranking one will take precedence.

**Automatic Bumping:** If no `#major`, `#minor` or `#patch` tag is contained in the commit messages, it will bump whichever `DEFAULT_BUMP` is set to (which is `patch` by default).

> ***Note:*** This action **will not** bump the tag if the `HEAD` commit has already been tagged.

### Workflow

* Add this action to your repo
* Setup a .bumpversion.cfg file in the root of your repo
  * Note: See the [.bumpversion.cfg](.bumpversion.cfg) in this repo for an example
* Commit some changes
* Either push to master or open a PR
* On push (or merge) to `master`, the action will:
  * Bump current tag with patch version unless any commit message contains `#major` or `#minor`
  * Bump the version of any files specified in the .bumpversion.cfg file

### Credits

[anotherNick/github-tag-action](https://github.com/anothrNick/github-tag-action/) - I used this repo extensively as a base for this project
