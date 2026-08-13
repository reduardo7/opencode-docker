FROM ghcr.io/anomalyco/opencode:latest

RUN apk update \
  && apk add --no-cache git github-cli glab openssh-client python3 py3-pip \
  && rm -rf /var/cache/apk/*

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
