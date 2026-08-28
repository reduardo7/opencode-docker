FROM python:3.10-alpine AS python

FROM ghcr.io/anomalyco/opencode:latest

RUN apk update \
  && apk add --no-cache git github-cli glab openssh-client bash curl pax-utils build-base linux-headers

RUN curl -fsSL https://unofficial-builds.nodejs.org/download/release/v24.13.0/node-v24.13.0-linux-x64-musl.tar.gz \
    | tar -xz -C /usr/local --strip-components=1 \
  && node --version \
  && npm --version

COPY --from=python /usr/local /usr/local

RUN find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    | xargs -r apk add --no-cache \
  && rm -rf /var/cache/apk/*

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
ENV GH_TOKEN_AUTH=""
ENV GH_GIT_PROTOCOL=""
ENV GLAB_TOKEN=""
ENV GLAB_GIT_PROTOCOL=""
ENV ENTRYPOINT_CMD=""
ENV EXEC_TIMEOUT=""

RUN mkdir /workspace
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
