---
name: add-software
description: "Adds a new software package to a vscode-devcontainer Dockerfile. Analyzes the OS, existing dependencies, and correct placement before writing to a new version directory. Includes security verification to prevent supply-chain attacks."
targets: ["*"]
claudecode:
  skills:
    - dockerfile-authoring
    - verify-dependency-security
  allowed-tools: Read, Write, Edit, Bash(find *), Bash(ls *), Bash(mkdir *), WebSearch, WebFetch
  disable-model-invocation: true
---

# Add Software

Adds a new software package to a `vscode-devcontainer` Dockerfile, correctly selecting the installation method, version, and placement. If the Go or Node.js major versions remain unchanged, the command **overwrites the existing Dockerfile**. If a major version changes, it **creates a new version directory**.

## Procedure

### Phase 1: Identify the Target Dockerfile and Software

1. If the user specified a Dockerfile path, use it. Otherwise, list available version directories:

   ```bash
   find vscode-devcontainer/versions -name "Dockerfile" | sort
   ```

   Present the list and ask the user to confirm which one to base the new version on.

2. Read the selected Dockerfile in full.

3. Confirm with the user:
   - **Package name**: the software to add (e.g. `fzf`, `ripgrep`, `terraform`)
   - **Requested version** (or "latest stable")
   - Any special requirements (specific arch support, configuration, PATH changes)

### Phase 2: Research the Package

1. Determine the **installation method** by checking how the package is distributed:
   - **apt package**: availability on Debian trixie (`apt-cache show <name>`)
   - **Go module**: `go install` support on pkg.go.dev or GitHub
   - **npm package**: published on npmjs.com
   - **GitHub Release binary**: pre-built binaries on the project's GitHub releases page
   - **Custom installer**: any other method (shell script, pip, etc.)

2. Find the **latest stable version**:
   - Use WebSearch to find the official releases page or package registry.
   - Reject pre-release versions containing: `-alpha`, `-beta`, `-rc`, `-pre`, `-dev`.
   - Note the exact version string format used by the project (bare semver vs. `v`-prefixed).

3. Confirm **multi-architecture support** (`linux/amd64` and `linux/arm64`):
   - If both are supported via the same release artifact, document the arch flag/variable.
   - If one arch requires a different approach (e.g. build from source), plan both paths.
   - Every tool must run on both architectures — no amd64-only additions.

### Phase 3: Determine Placement

Apply the **dockerfile-authoring** skill's placement decision tree:

1. Is it a Go binary? → Stage 1 `tool-builder`, ENV + `go install`.
2. Standard Debian package available in trixie? → Existing `apt-get install` block.
3. npm package? → Existing `npm install -g` block + ENV.
4. GitHub Release binary? → New labeled section in the final stage.
5. Custom installer? → New labeled section; document any arch special-casing.

Identify the exact position in the file for the new block, following the **Placement Order** defined in the dockerfile-authoring skill.

### Phase 4: Security Verification

**CRITICAL**: Before presenting the plan for approval, verify that the new software package does not introduce security risks.

Apply the **verify-dependency-security** skill to the new package.

Pass:

- Package name
- Current version: `(none — new addition)`
- Proposed version: the resolved version from Phase 2
- Source type: the installation method determined in Phase 2
- Package URL: the official repository or registry URL

The security verification will produce a risk assessment, including:

- Known vulnerabilities (CVEs) in the proposed version
- Suspicious release patterns (supply-chain attack indicators)
- Trust signals (repository activity, community trust, maintainer history)

**If the package is flagged as High or Critical risk:**

1. Present the security report to the user immediately.
2. Ask whether to:
   - **Select a different version** (find an earlier, patched version)
   - **Proceed anyway** (user accepts the risk)
   - **Cancel** the addition

**If the package is Low or Medium risk:**

- Include the security summary in the next phase (approval).
- Medium-risk packages should be highlighted for user awareness but do not block approval.

Do not proceed to Phase 5 if the package is Critical-risk without explicit user override.

### Phase 5: Present the Plan for Approval

Show the user:

- **Package**: name and resolved version string
- **Security summary**: Risk level (Low / Medium / High / Critical) from Phase 4
- **Installation method**: source type
- **Arch support**: both arches covered? any fallback needed?
- **Placement**: which stage and position in the file
- **Exact diff**: the new ENV line(s) and RUN step to be added (formatted as they will appear in the Dockerfile)

Use your interactive confirmation capability to request explicit user approval before writing any files. The user may request adjustments to the version, placement, or method before approving.

### Phase 6: Write the Updated Dockerfile

1. Determine the target directory name:
   - Keep the same `go<major.minor>-node<major>` name unless Go or Node versions changed.
   - If the name matches the current directory, you will overwrite the existing Dockerfile.
   - If the name differs (because a major version changed), create a new directory. If it already exists, append `-2` (or the next available suffix) and inform the user.

2. Create the new directory if needed:

   ```bash
   mkdir -p vscode-devcontainer/versions/<target-dir>/
   ```

3. Copy the source Dockerfile content, inserting the new software block at the approved location. Apply only the additions — do not alter any existing content.

4. Write the result to `vscode-devcontainer/versions/<target-dir>/Dockerfile`.

5. Re-read the written file and verify:
   - The new ENV variable and RUN step are present and correctly formatted.
   - All existing content is unchanged.
   - Version string format matches the upstream format.

Report any discrepancies before continuing.

### Phase 7: Report and Next Steps

Report:

- Updated Dockerfile path
- Whether the file was overwritten or a new directory was created
- Package name, version, and installation method used
- **Security summary**: Package passed security verification (or note if Medium-risk and was approved)
- Placement in the file

Remind the user of next steps:

1. **Build and smoke-test**: use the `test` command or run `docker build vscode-devcontainer/versions/<target-dir>/`.
2. **Verify the new binary**: `docker run --rm devcontainer-test:local <binary> --version`.
3. **Push a git tag** with the appropriate `filter_ref` to trigger CI (see `.github/workflows/main.yml`).

## Important Considerations

- **Version directory policy**: Overwrite the existing Dockerfile if Go/Node.js major versions remain unchanged. Create a new directory only when a major version changes (e.g., Go 1.26 → 1.27, or Node 25 → 26).
- **Version always pinned**: Never use `@latest` for a new tool (except `gopls` and `goimports`, which are intentionally unpinned).
- **Arch support is mandatory**: Every added tool must run on both `linux/amd64` and `linux/arm64`. Document any build-from-source fallback using the Archgate section in the Dockerfile as a reference pattern.
- **Confirm before write**: Show the full planned diff and get explicit approval before Phase 5.
- **Minimal diff**: Only add the new tool. Preserve all existing comments, whitespace, and structure.
