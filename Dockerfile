FROM python:3.10-alpine AS python

FROM ghcr.io/anomalyco/opencode:latest

RUN apk update \
  && apk add --no-cache git github-cli glab openssh-client bash curl libffi openssl zlib sqlite-libs ncurses-libs readline \
  && rm -rf /var/cache/apk/*

COPY --from=python /usr/local /usr/local

RUN curl -fsSL https://bun.sh/install | bash
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

ENV BUN_INSTALL="/root/.bun"
ENV PATH="/root/.bun/bin:/root/.nvm:$PATH"
ENV NVM_DIR="/root/.nvm"

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
