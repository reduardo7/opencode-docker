#!/bin/sh
set -e

git config --global --add safe.directory /workspace

if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

if [ -n "$GH_TOKEN_AUTH" ]; then
    echo "$GH_TOKEN_AUTH" | gh auth login --with-token
    gh auth setup-git
fi

if [ -n "$GH_GIT_PROTOCOL" ]; then
    gh config set git_protocol "$GH_GIT_PROTOCOL" --host github.com
fi

if [ -n "$GLAB_TOKEN" ]; then
    echo "$GLAB_TOKEN" | glab auth login --stdin
fi

if [ -n "$GIT_SSH_KEY" ]; then
    mkdir -p ~/.ssh
    echo "$GIT_SSH_KEY" > ~/.ssh/git_key
    chmod 600 ~/.ssh/git_key
    cat >> ~/.ssh/config <<'SSHCFG'

Host github.com gitlab.com bitbucket.org
    IdentityFile ~/.ssh/git_key
SSHCFG
    chmod 600 ~/.ssh/config
fi

if [ -n "$GLAB_GIT_PROTOCOL" ]; then
    glab config set git_protocol "$GLAB_GIT_PROTOCOL"
fi

CMD="${ENTRYPOINT_CMD:-opencode}"

if [ -n "$EXEC_TIMEOUT" ]; then
    if echo "$EXEC_TIMEOUT" | grep -qE '^[0-9]+$'; then
        timeout "$EXEC_TIMEOUT" "$CMD" "$@"
    else
        echo "WARNING: EXEC_TIMEOUT='$EXEC_TIMEOUT' is not a valid integer. Ignoring timeout." >&2
        "$CMD" "$@"
    fi
else
    "$CMD" "$@"
fi
