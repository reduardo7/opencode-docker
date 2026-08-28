# AGENTS.md

Docker image repo for opencode. Not an application — there is no app code, test suite, or linter. The deliverable is a Docker image; publish happens only through GitHub Actions CI, never locally.

## What the repo is

- `Dockerfile` — base is upstream `ghcr.io/anomalyco/opencode:latest`; adds `git`, `gh`, `glab`, `openssh-client` via apk. Declares the ENV defaults. `WORKDIR` is `/workspace`.
- `docker/entrypoint.sh` — the entire runtime logic. All behavior is driven by environment variables (git user config, gh/glab auth, SSH key, command override, timeout). See README table for the full list.
- `README.md` — canonical source for env vars and usage examples.
- `.github/workflows/build-publish.yml` — builds and pushes `ghcr.io/<owner>/opencode` and `docker.io/<owner>/opencode`.
- `.opencode/` — opencode's own plugin config (a `/add-image-build` command), not part of the image.
- `.codesearch.db` — local, gitignored artifact.

## Variant branches

Branch == image tag. Each branch has its own `Dockerfile` installing different packages on top of the same base:

- `main` → `latest`: base set only (`git`, `gh`, `glab`, `openssh-client`).
- `python` → `python`: adds `python3`, `py3-pip`.
- `node` → `node`: adds `bash`, `curl`, `pax-utils`, `build-base`, `linux-headers`, Python (copied from `python:3.10-alpine`), plus `bun` and `nvm`.
- `node-24` → `node-24`: same as `node`, but installs Node v24.13.0 from `unofficial-builds.nodejs.org` (musl build) instead of relying on nvm only.

- Each variant branch carries a **single-variant** `build-publish.yml` (builds only itself, no matrix, `ref:` hardcoded to the branch).
- `main`'s workflow builds **all four** tags via `strategy.matrix.include`.
- When adding a new variant, both the branch's workflow and `main`'s matrix entry must be updated together. The repo ships a command for this: `/add-image-build <branch>` (spec in `.opencode/command/add-image-build.md`). It commits locally on both branches but never pushes.

## Build / verify

No lint, typecheck, or tests. The only local verification is building the image:

```bash
docker build -t opencode-docker .
```

CI triggers (`.github/workflows/build-publish.yml`): push to a variant branch, `cron: '0 */6 * * *'` schedule, `repository_dispatch` type `opencode-published`, and `workflow_dispatch`. The schedule uses a digest-cache key to skip rebuilding when the upstream base image hasn't changed.

## Conventions

- Config changes to the image's behavior go in `docker/entrypoint.sh` (and the `ENV` lines in `Dockerfile`), not in CI.
- Keep `README.md` env-var table in sync when adding/removing a variable.
- Don't add comments unless asked (matches repo style).
