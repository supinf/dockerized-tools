---
root: true
targets: ["*"]
description: "Project overview and general development guidelines"
globs: ["**/*"]
---

# Project Overview

`supinf/dockerized-tools` — a collection of Dockerized tool images organized by language/runtime. Images are published to `ghcr.io/supinf/` via tag-triggered GitHub Actions.

## Repository Structure

```
<language|runtime>/
  <tool-name>/
    versions/
      <version>/
        Dockerfile
    README.md        # usage examples (where present)
```

Categories: `golang/`, `python/`, `nodejs/`, `java/`, `ruby/`, `haskell/`, `c/`, `cli-tools/`, `vscode-devcontainer/`

## Image Status

| Image                 | Status                                      |
| --------------------- | ------------------------------------------- |
| `vscode-devcontainer` | ✅ Active — primary development environment |
| All others            | ⚠️ Legacy — maintained only as needed       |

The `vscode-devcontainer` image (`vscode-devcontainer/versions/go1.26-node25/`) is a multi-stage Debian-based image bundling Go, Node.js, and a wide set of development tools (golangci-lint, buf, protoc plugins, flyway, gh, Docker, AWS CLI, Claude Code, Gemini CLI, etc.).

## Critical Rules

- **No edits to generated AI config files** — `.claude/`, `.cursor/`, `.gemini/`, `.roo/`, `CLAUDE.md`, `GEMINI.md` etc. are auto-generated. Edit source files under `.rulesync/` and run `bash .rulesync/rulesync.sh` to regenerate.
- **Version directory policy** — directory names follow `go<major.minor>-node<major>` format. You may overwrite an existing Dockerfile if the Go/Node.js major versions remain unchanged. Create a new version directory only when a major version changes (e.g., Go 1.26 → 1.27, or Node 25 → 26).
- **One Dockerfile per version directory** — keep each `versions/<tag>/` self-contained.
- **Tag-based CI** — releases are triggered by git tags. Each image in `main.yml` has a `filter_ref`; push a tag containing that string to build and push only that image.
- **Registry target** — all new images go to `ghcr.io/supinf/<image-name>:<tag>` (not Docker Hub).

## CI / Release Workflow

1. Edit or add `versions/<tag>/Dockerfile` for the target image.
2. Build and smoke-test locally: `docker build <path>`.
3. Push a git tag that includes the image's `filter_ref` value (defined in `.github/workflows/main.yml`).
4. GitHub Actions builds and pushes to `ghcr.io/supinf/`.

## Workflow

- **Plan first**: Present an implementation plan and wait for user approval before making significant changes.
- **rulesync**: After editing any file under `.rulesync/`, regenerate agent configs with `bash .rulesync/rulesync.sh`.

## Language & Communication

- **Responses**: All responses and descriptions to the user MUST be in **Japanese** (日本語). This is VERY IMPORTANT!
- **Code comments**: Write in Japanese, except variable/function names and commit messages (those stay in English).
- **Human-in-the-loop**: When asking for permission or clarification, use clear and polite Japanese.
