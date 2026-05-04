---
name: dockerfile-authoring
description: Conventions and patterns for writing Dockerfiles in this repository. Use when creating a new Dockerfile or adding software to an existing one.
---

# Dockerfile Authoring

Guidelines and patterns for writing and modifying Dockerfiles in `vscode-devcontainer/versions/`.

## Stage Architecture

The `vscode-devcontainer` Dockerfile uses three stages:

| Stage | Base Image | Purpose |
|---|---|---|
| `go-sdk` | `golang:${GO_VERSION}-bookworm` | Provides the Go SDK for the final stage |
| `tool-builder` | `golang:${GO_VERSION}-bookworm` (with `--platform=$BUILDPLATFORM`) | Cross-compiles Go CLI tools |
| *(unnamed final stage)* | `debian:${DEBIAN_VERSION}` | The actual devcontainer image |

## Global Arguments

Declare `ARG` values that are referenced across multiple stages at the top of the file, before any `FROM`:

```dockerfile
ARG GO_VERSION=1.26.2
ARG DEBIAN_VERSION=trixie-20260421
```

## Go Tools (Stage 1 — tool-builder)

Go-based CLI tools are compiled in `tool-builder` and copied into the final stage via `COPY --from=tool-builder /go/bin /go/bin`.

**To add a Go tool:**
1. Add its version as an `ENV` variable in the `ENV` block at the top of Stage 1.
2. Add the corresponding `go install` line in the `RUN` block.
3. Keep alphabetical order within the ENV block where possible.

```dockerfile
ENV NEW_TOOL_VERSION=v1.2.3
    ...

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    ...
    go install github.com/example/new-tool@${NEW_TOOL_VERSION} && \
    ...
```

`CGO_ENABLED=0`, `GOOS=linux`, `GOARCH=${TARGETARCH}` are already set via `ENV` at the top of Stage 1.

## System Packages (apt) — Final Stage

Add apt packages to the existing `apt-get install` block at the beginning of the final stage. Keep `--no-install-recommends` and the trailing cleanup:

```dockerfile
RUN --mount=type=cache,target=/var/cache/apt/archives,id=apt-archives-${TARGETARCH} \
    apt-get update && apt-get install -y --no-install-recommends \
    <existing packages> \
    <new-package> \
    && localedef ... \
    && rm -rf /var/lib/apt/lists/*
```

Do **not** add a separate `apt-get update && apt-get install` call unless the package requires a custom apt source (like Docker or GitHub CLI).

## Node.js Tools (npm) — Final Stage

npm packages are installed in a dedicated `RUN --mount=type=cache,target=/root/.npm` block:

```dockerfile
ENV NPM_VERSION=11.13.0 \
    PNPM_VERSION=10.33.0 \
    NEW_TOOL_VERSION=1.2.3

RUN --mount=type=cache,target=/root/.npm \
    npm install -g "npm@${NPM_VERSION}" --force && \
    npm install -g "pnpm@${PNPM_VERSION}" && \
    npm install -g "new-tool@${NEW_TOOL_VERSION}" && \
    npm cache clean --force
```

Add the `ENV NEW_TOOL_VERSION=...` declaration alongside the other npm-related ENV vars above this block.

## GitHub Release Binaries — Final Stage

Use `curl` to download from GitHub Releases. Group similar tools together and use a dedicated labeled section:

```dockerfile
# ------------------------------------------------------------------------------
# Tool Name
# ------------------------------------------------------------------------------
ENV TOOL_VERSION=1.2.3

RUN case ${TARGETARCH} in \
         "amd64") TOOL_ARCH="x64"  ;; \
         "arm64") TOOL_ARCH="arm64" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/owner/repo/releases/download/v${TOOL_VERSION}/tool_${TOOL_VERSION}_linux_${TOOL_ARCH}.tar.gz" -o tool.tar.gz && \
    tar -xzf tool.tar.gz -C /usr/local/bin tool && \
    rm tool.tar.gz
```

If the tool has no architecture variants, omit the `case` block.

## Deciding Where to Place a New Tool

Apply this decision tree:

1. **Is it a Go binary?** → Stage 1 (`tool-builder`), installed via `go install`.
2. **Is it a standard Debian package?** → Add to the existing `apt-get install` block.
3. **Is it an npm package?** → Add to the `npm install -g` block. Add `ENV` nearby.
4. **Is it a GitHub Release binary?** → New labeled section in the final stage, after similar tools.
5. **Does it require a custom installer or build step?** → New labeled section. Document any architecture special-casing.

## Placement Order in the Final Stage

Maintain this rough ordering in the final stage for readability:

1. `apt-get install` block (base system packages)
2. Flyway (maven-central)
3. OpenAPI Generator (GitHub raw script)
4. GitHub CLI (custom apt source)
5. Python tools (uv installer)
6. Node.js + npm tools
7. Docker (custom apt source)
8. AWS CLI
9. Claude Code (ENV only, no install step)
10. Gemini CLI (npm)
11. Archgate (npm / bun build for arm64)
12. Other GitHub Release binaries (Gitleaks, etc.)
13. Go SDK and tool binaries (COPY from earlier stages)

When adding a new tool, insert it in the logically closest group. Add a `# ---` separator comment block with the tool name.

## Version Variables

- Always pin versions via `ENV` or global `ARG` — never hardcode a version string inline.
- Use `v`-prefixed semver when that is the upstream format; use bare semver otherwise.
- Variable name: `<TOOLNAME>_VERSION` in SCREAMING_SNAKE_CASE.

## Architecture Support

All tools must support both `linux/amd64` and `linux/arm64`. If a pre-built binary is only available for one arch, provide a source-build fallback for the other (see Archgate section in the Dockerfile for the pattern).

## Version Directory Policy

Directory names follow the pattern `go<major.minor>-node<major>`, derived from the Go and Node.js major versions in use.

**You may overwrite an existing Dockerfile** if the Go or Node.js major versions remain unchanged (e.g., Go 1.26.1 → 1.26.2, or Node 25.1 → 25.3).

**Create a new version directory** only when a major version changes:
- Go major.minor changes (e.g., 1.26 → 1.27)
- Node.js major version changes (e.g., 25 → 26)

In these cases, create a new directory:

```
vscode-devcontainer/versions/<new-tag>/Dockerfile
```
