FROM python:3-alpine
LABEL maintainer="Jon Aumann"
LABEL repository="https://github.com/jaumann/github-bumpversion-action"
LABEL homepage="https://github.com/jaumann/github-bumpversion-action"

# Install our pre-reqs
RUN apk add --no-cache git


# Check to make sure pip is fully upgraded
RUN pip install --no-cache-dir -U pip

# Install bumpversion from pypi - https://pypi.org/project/bumpversion/
RUN pip install --no-cache-dir bumpversion

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
