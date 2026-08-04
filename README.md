# OpenCode Docker

Docker image for [opencode](https://github.com/anomalyco/opencode) with dynamic configuration support for Git CLI tools.

Built on top of the [official OpenCode image](https://github.com/anomalyco/opencode/pkgs/container/opencode). See the [OpenCode documentation](https://opencode.ai/docs/) for more details.

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

## Usage

### Build the image

```bash
docker build -t opencode-docker .
```

### Basic example

```bash
docker run -it --rm \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@email.com" \
  opencode-docker
```

### With GitHub authentication

```bash
docker run -it --rm \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@email.com" \
  -e GH_TOKEN="ghp_yourToken" \
  -e GH_GIT_PROTOCOL="ssh" \
  opencode-docker
```

### With GitLab authentication

```bash
docker run -it --rm \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="you@email.com" \
  -e GLAB_TOKEN="glpat-yourToken" \
  -e GLAB_GIT_PROTOCOL="ssh" \
  opencode-docker
```
