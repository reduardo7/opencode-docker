FROM ghcr.io/anomalyco/opencode:latest

RUN apk update && apk add --no-cache git github-cli glab && rm -rf /var/cache/apk/*

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV GIT_USER_NAME=""
ENV GIT_USER_EMAIL=""
ENV GIT_SSH_KEY=""

ENTRYPOINT ["/entrypoint.sh"]
