FROM ghcr.io/anomalyco/opencode:latest

RUN apk update \
  && apk add --no-cache git github-cli glab openssh-client bash curl \
  && rm -rf /var/cache/apk/*

RUN curl -fsSL https://bun.sh/install | bash \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

ENV BUN_INSTALL="/root/.bun" \
    PATH="/root/.bun/bin:/root/.nvm:$PATH" \
    NVM_DIR="/root/.nvm"

RUN mkdir -p ~/.ssh \
  && ssh-keyscan github.com gitlab.com bitbucket.org >> ~/.ssh/known_hosts \
  && chmod 600 ~/.ssh/known_hosts

RUN cat > ~/.ssh/config <<'SSHCFG'
Host github.com gitlab.com bitbucket.org
    StrictHostKeyChecking accept-new
SSHCFG

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV GIT_USER_NAME=""
ENV GIT_USER_EMAIL=""
ENV GIT_SSH_KEY=""

RUN mkdir /workspace
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
