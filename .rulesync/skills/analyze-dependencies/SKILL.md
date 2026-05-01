---
name: analyze-dependencies
description: Reads one or more Dockerfiles and produces a structured catalog of every pinned dependency version, grouped by source type (go-module, npm-package, github-release, maven-central, debian-snapshot). Use when preparing a version-update workflow, auditing dependency freshness, or identifying which packages in a Dockerfile need a version bump.
---

# Analyze Dependencies

Extracts every version-pinned dependency from a Dockerfile and groups it by source type so the next step knows exactly where to look for newer releases.

## Instructions

### Step 1: Locate the Target Dockerfile

Read the Dockerfile path supplied by the caller. If none is given, find the most recently named version directory under `vscode-devcontainer/versions/` and read its `Dockerfile`.

### Step 2: Extract All Versioned Entries

Scan the file for version strings in these patterns:

| Pattern                                        | Example                          |
| ---------------------------------------------- | -------------------------------- |
| `ARG NAME=value` at global scope               | `ARG GO_VERSION=1.26.1`          |
| `ENV NAME=value` in any stage                  | `ENV FLYWAY_VERSION=9.9.0`       |
| Multi-line `ENV` blocks                        | `TBLS_VERSION=v1.94.4 \`         |
| Inline version in a `RUN` command (no ENV var) | `@v1.2.3` in a `go install` line |

### Step 3: Assign Source Type to Each Entry

| Source Type       | Signals                                                       |
| ----------------- | ------------------------------------------------------------- |
| `go-module`       | installed via `go install <module>@${VAR}`                    |
| `npm-package`     | installed via `npm install -g "pkg@${VAR}"`                   |
| `github-release`  | downloaded via `curl` from `github.com/…/releases/download/…` |
| `maven-central`   | downloaded via `curl` from `repo1.maven.org/maven2/…`         |
| `debian-snapshot` | a dated Debian suite tag (e.g. `trixie-20260406`)             |
| `unpinned`        | installed with `@latest` — intentionally unversioned; skip    |

### Step 4: Identify Coordination Constraints

Flag pairs or groups where a version change in one entry requires a matching change in another:

- **Go SDK ↔ Delve**: `GO_VERSION` and `DELVE_VERSION` must be compatible — Delve tracks the Go major version.
- **Archgate version ↔ SHA**: `ARCHGATE_VERSION` always has a companion `ARCHGATE_GIT_SHA` that must be updated together. The SHA is obtained via `npm view archgate@<version> gitHead`.
- **Debian suite ↔ apt packages**: Changing `DEBIAN_VERSION` affects all packages installed from apt.

### Step 5: Output the Catalog

Produce a Markdown table followed by a coordination warnings section.

```
## Dependency Catalog

| Variable | Current Version | Package / Module | Source Type | Coordination |
|---|---|---|---|---|
| GO_VERSION | 1.26.1 | golang | github-release | Update DELVE_VERSION together |
| DEBIAN_VERSION | trixie-20260406 | debian:trixie | debian-snapshot | Affects all apt installs |
| TBLS_VERSION | v1.94.4 | github.com/k1LoW/tbls | go-module | none |
| ... | ... | ... | ... | ... |

## Unpinned (Skip)
- gopls — installed @latest intentionally
- goimports — installed @latest intentionally

## Coordination Warnings
- GO_VERSION and DELVE_VERSION must be updated together.
- ARCHGATE_VERSION requires ARCHGATE_GIT_SHA to be updated via `npm view archgate@<version> gitHead`.
```

## Common Issues

**Multi-architecture variables**: Some tools set an arch-specific variable (e.g. `GITLEAKS_ARCH`) derived from `TARGETARCH`. Catalog the base version ENV var only; ignore the arch-selector.

**Inline versions with no ENV var**: If a version string appears directly in a `RUN` command without a backing ENV var, add it to the catalog as `(inline)` in the Variable column and flag it for extraction into an ENV var before updating.

**`FROM` image tags**: Include the base image tags (e.g. `golang:${GO_VERSION}-bookworm`, `debian:${DEBIAN_VERSION}`) as implicit consumers of the ARG values — do not add them as separate rows.
