#!/bin/sh
set -e

if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

if [ -n "$GH_TOKEN" ]; then
    echo "$GH_TOKEN" | gh auth login --with-token
fi

if [ -n "$GH_GIT_PROTOCOL" ]; then
    gh config set git_protocol "$GH_GIT_PROTOCOL" --host github.com
fi

if [ -n "$GLAB_TOKEN" ]; then
    echo "$GLAB_TOKEN" | glab auth login --stdin
fi

if [ -n "$GLAB_GIT_PROTOCOL" ]; then
    glab config set git_protocol "$GLAB_GIT_PROTOCOL"
fi

exec "$@"
