FROM ghcr.io/anomalyco/opencode:latest

RUN apk update && apk add --no-cache git gh glab

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV GIT_USER_NAME=""
ENV GIT_USER_EMAIL=""

ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh"]
