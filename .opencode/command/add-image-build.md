---
description: Add an automatic Docker image build for a variant branch (single-variant workflow on the branch + matrix entry on main). Usage: /add-image-build <branch>
---

Add an automatic Docker image build for a variant branch, exactly like the existing `python` and `node` branches. The branch name comes from `$1`.

Rules:
- Only commit locally. Never run `git push`.
- Commit on each branch that is modified (the variant branch and `main`).
- Do not modify the `Dockerfile` or any other file; only `.github/workflows/build-publish.yml`.

Steps:

1. Let `BRANCH` = `$1`. If it is empty, ask the user for the branch name and stop.

2. Record the current branch as `ORIGINAL_BRANCH` (`git rev-parse --abbrev-ref HEAD`).

3. `git checkout BRANCH`.

4. Rewrite `.github/workflows/build-publish.yml` on this branch so it builds ONLY this branch. Match the `python`/`node` shape exactly:
   - `on.push.branches: [BRANCH]` (remove any `tags: ['v*']`).
   - No `strategy.matrix` block (remove it if present).
   - Checkout step gets `with: { ref: BRANCH }`.
   - Docker metadata `tags:` becomes `type=raw,value=BRANCH` (drop `type=ref`, `type=sha`, and any `latest`/`main` logic).
   - Both `key:` cache lines use `upstream-digest-${{ steps.upstream.outputs.digest }}` (no `matrix.tag`).
   - Keep the `schedule`, `repository_dispatch`, and `workflow_dispatch` triggers as-is.

   Final file must look like this (replace `BRANCH`):

```yaml
name: Build and Publish Docker Image

on:
  push:
    branches: [BRANCH]
  schedule:
    - cron: '0 */6 * * *'
  repository_dispatch:
    types: [opencode-published]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  DOCKERHUB_REGISTRY: docker.io
  IMAGE_NAME: opencode
  UPSTREAM_IMAGE: ghcr.io/anomalyco/opencode:latest

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          ref: BRANCH

      - name: Pull upstream base image
        run: docker pull ${{ env.UPSTREAM_IMAGE }}

      - name: Get upstream image digest
        id: upstream
        run: |
          DIGEST=$(docker inspect --format='{{.RepoDigests}}' ${{ env.UPSTREAM_IMAGE }} | grep -o 'sha256:[^]]*')
          echo "digest=$DIGEST" >> $GITHUB_OUTPUT

      - name: Check for changes
        id: check
        uses: actions/cache/restore@v4
        with:
          path: /tmp
          key: upstream-digest-${{ steps.upstream.outputs.digest }}
          lookup-only: true

      - name: Log in to GitHub Container Registry
        if: ${{ steps.check.outputs.cache-hit != 'true' || github.event_name != 'schedule' }}
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Log in to Docker Hub
        if: ${{ steps.check.outputs.cache-hit != 'true' || github.event_name != 'schedule' }}
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKERHUB_REGISTRY }}
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Docker metadata
        id: meta
        if: ${{ steps.check.outputs.cache-hit != 'true' || github.event_name != 'schedule' }}
        uses: docker/metadata-action@v5
        with:
          images: |
            ${{ env.REGISTRY }}/${{ github.repository_owner }}/${{ env.IMAGE_NAME }}
            ${{ env.DOCKERHUB_REGISTRY }}/${{ secrets.DOCKERHUB_USERNAME }}/${{ env.IMAGE_NAME }}
          tags: |
            type=raw,value=BRANCH

      - name: Build and push Docker image
        if: ${{ steps.check.outputs.cache-hit != 'true' || github.event_name != 'schedule' }}
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

      - name: Cache upstream digest
        if: ${{ steps.check.outputs.cache-hit != 'true' && github.event_name == 'schedule' }}
        uses: actions/cache/save@v4
        with:
          path: /tmp
          key: upstream-digest-${{ steps.upstream.outputs.digest }}
```

5. `git add .github/workflows/build-publish.yml && git commit -m "ci: build BRANCH variant and publish BRANCH tag only"`.

6. `git checkout main`.

7. In main's `.github/workflows/build-publish.yml`, append a new entry to the `strategy.matrix.include` list (after the existing entries):

```yaml
          - ref: BRANCH
            tag: BRANCH
```

8. `git add .github/workflows/build-publish.yml && git commit -m "ci: add BRANCH variant to build matrix"`.

9. `git checkout ORIGINAL_BRANCH`.

Report which branches were committed (BRANCH and main) and their commit hashes. Remind the user that nothing was pushed.
