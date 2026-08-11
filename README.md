# OpenCode Docker

Docker image for [opencode](https://github.com/anomalyco/opencode) with dynamic configuration support for Git CLI tools.

Built on top of the [official OpenCode image](https://github.com/anomalyco/opencode/pkgs/container/opencode) and automatically rebuilt when a new upstream version is published.

Pre-built image available at: [`ghcr.io/reduardo7/opencode`](https://github.com/reduardo7/opencode-docker/pkgs/container/opencode)

Includes:
- **git** — version control
- **gh** — GitHub CLI
- **glab** — GitLab CLI

## Environment variables

| Variable | Tool | Description |
|---|---|---|
| `GIT_USER_NAME` | git | Commit user name |
| `GIT_USER_EMAIL` | git | Commit email |
| `GH_TOKEN` | gh | GitHub authentication token |
| `GH_GIT_PROTOCOL` | gh | Git protocol (`ssh` or `https`) |
| `GLAB_TOKEN` | glab | GitLab authentication token |
| `GLAB_GIT_PROTOCOL` | glab | Git protocol (`ssh` or `https`) |
| `GIT_SSH_KEY` | git | Private SSH key for Git authentication |
| `ENTRYPOINT_CMD` | — | Command to execute instead of `opencode` (default: `opencode`) |
| `EXEC_TIMEOUT` | — | Timeout in seconds for the executed command (optional, no timeout if unset) |

## Usage

### Pull the image

```bash
docker pull ghcr.io/reduardo7/opencode:latest
```

### Build locally (optional)

```bash
docker build -t opencode-docker .
```

### Basic example

```bash
docker run -it --rm \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@email.com" \
  ghcr.io/reduardo7/opencode:latest
```

### With GitHub authentication

```bash
docker run -it --rm \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@email.com" \
  -e GH_TOKEN="ghp_yourToken" \
  -e GH_GIT_PROTOCOL="ssh" \
  ghcr.io/reduardo7/opencode:latest
```

### With GitLab authentication

```bash
docker run -it --rm \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@email.com" \
  -e GLAB_TOKEN="glpat-yourToken" \
  -e GLAB_GIT_PROTOCOL="ssh" \
  ghcr.io/reduardo7/opencode:latest
```

### With SSH key (without gh or glab)

```bash
docker run -it --rm \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@email.com" \
  -e GIT_SSH_KEY="$(cat ~/.ssh/id_ed25519)" \
  ghcr.io/reduardo7/opencode:latest
```
