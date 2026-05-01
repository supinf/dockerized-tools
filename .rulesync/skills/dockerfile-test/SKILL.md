---
name: dockerfile-test
description: Procedures for building and smoke-testing a vscode-devcontainer Dockerfile locally. Use when validating a new or modified Dockerfile before release.
---

# Dockerfile Test

Steps for locally building a Dockerfile and verifying that the resulting image works correctly.

## Step 1: Identify the Target Dockerfile

Read the Dockerfile path supplied by the caller. If none is given, find the most recently created version directory:

```bash
find vscode-devcontainer/versions -name "Dockerfile" | sort | tail -1
```

## Step 2: Build the Image

Run `docker build` with `--progress=plain` to show full output. For the `vscode-devcontainer` image, the build context is the directory containing the Dockerfile:

```bash
docker build --progress=plain \
  -t devcontainer-test:local \
  vscode-devcontainer/versions/<tag>/
```

To test a specific platform explicitly:

```bash
docker build --progress=plain --platform linux/amd64 \
  -t devcontainer-test:local \
  vscode-devcontainer/versions/<tag>/
```

Report the full build log. If the build fails, show the last 50 lines of output and stop — do not proceed to smoke testing.

## Step 3: Identify Tools to Verify

From the Dockerfile, identify the key binaries that should be present in the final image. Focus on:

- Tools added or modified in this version
- Canary tools that confirm each installation method works (one per source type)

Example canary set:

| Binary | Source Type |
|---|---|
| `go version` | Go SDK (COPY from go-sdk stage) |
| `dlv version` | Go tool (go install) |
| `golangci-lint --version` | Go tool (go install) |
| `node --version` | Node.js (apt/nodesource) |
| `flyway -v` | Maven Central |
| `gh --version` | GitHub CLI (custom apt) |
| `aws --version` | AWS CLI (custom installer) |
| `docker --version` | Docker (custom apt) |
| `buf --version` | Go tool |
| `gitleaks version` | GitHub Release binary |

## Step 4: Run Smoke Tests

Run each binary with a version flag inside the image:

```bash
docker run --rm devcontainer-test:local go version
docker run --rm devcontainer-test:local dlv version
docker run --rm devcontainer-test:local golangci-lint --version
docker run --rm devcontainer-test:local node --version
docker run --rm devcontainer-test:local flyway -v
docker run --rm devcontainer-test:local gh --version
docker run --rm devcontainer-test:local aws --version
docker run --rm devcontainer-test:local docker --version
docker run --rm devcontainer-test:local buf --version
docker run --rm devcontainer-test:local gitleaks version
```

For each command, record: pass / fail and the output line.

If any binary is missing (`command not found`) or exits non-zero, report the error and investigate the Dockerfile for the root cause.

## Step 5: Report Results

Produce a summary table:

```
| Binary            | Expected Version | Actual Output                      | Status |
|---|---|---|---|
| go                | 1.26.2           | go version go1.26.2 linux/amd64    | PASS   |
| dlv               | v1.26.2          | Delve Debugger Version: 1.26.2     | PASS   |
| ...               | ...              | ...                                | ...    |
```

Highlight any failures and recommend fixes.

## Common Issues

**Multi-stage COPY failure**: If a Go binary is missing in the final image, check that the `go install` step succeeded in `tool-builder` and that `COPY --from=tool-builder /go/bin /go/bin` is present in the final stage.

**Architecture mismatch**: If building on Apple Silicon (arm64) and a binary is missing or crashes, try building explicitly with `--platform linux/arm64`. If a binary is only available for amd64, check the Dockerfile's architecture fallback logic.

**`docker: command not found` inside container**: The Docker CLI is installed but the daemon socket is not mounted inside the container — this is expected. Only test with `docker --version`, not with `docker ps` or `docker run`.

**`flyway -v` exits non-zero**: Flyway may print to stderr and exit 1 without a database connection. Treat any output containing the version number as a pass.
