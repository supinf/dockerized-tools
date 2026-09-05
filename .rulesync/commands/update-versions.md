---
name: update-versions
description: "Updates all pinned dependency versions in one or more Dockerfiles to their latest stable releases and writes the result in place (or into a new version directory when a major version changes). Runs analyze-dependencies, find-proper-software-version, and verify-dependency-security skills as sub-steps."
targets: ["*"]
claudecode:
  skills:
    - analyze-dependencies
    - find-proper-software-version
    - verify-dependency-security
  allowed-tools: Read, Write, Edit, Bash(find *), Bash(ls *), Bash(npm *), Bash(gh *), Bash(curl *), Bash(python3 *), Bash(bash .rulesync/rulesync.sh), WebSearch, WebFetch
  disable-model-invocation: true
---

# Update Dependency Versions

Brings every pinned dependency in a Dockerfile up to its latest stable release. If the Go or Node.js major versions remain unchanged, the command **overwrites the existing Dockerfile**. If a major version changes, it **creates a new version directory**.

## Procedure

### Phase 1: Identify the Target Dockerfile(s)

1. If the user specified one or more paths, use them. Otherwise, run:

   ```bash
   find vscode-devcontainer/versions -name "Dockerfile" | sort
   ```

   and present the list. Ask the user which version(s) to base the update on, or confirm the most recent one.

2. Read every selected Dockerfile in full.

3. For each selected Dockerfile, note the current version directory name (e.g. `go1.26-node25`). If the Go or Node.js major versions will change, a new directory will be created; otherwise, the existing Dockerfile will be overwritten.

4. **Multiple-file note**: if the user selects more than one Dockerfile (e.g. both `go1.27-node26/` and `node26/`), treat them as a single batch. Produce one consolidated dependency catalog that spans all files, noting which file each variable appears in and flagging version differences between files.

### Phase 2: Analyze Dependencies

Apply the **analyze-dependencies** skill to the Dockerfile content.

Produce the full dependency catalog as specified by that skill, including:

- Variable name and current version
- Package / module identifier
- Source type
- Coordination warnings

Present the catalog to the user so they can review scope before any web searches begin. Ask for confirmation to proceed, or allow exclusions (e.g. "skip FLYWAY_VERSION").

### Phase 3: Research Latest Stable Versions

**Parallelize aggressively**: spawn multiple agents simultaneously, one per logical group (go-modules, npm-packages, github-releases, etc.), so all lookups complete in a single wall-clock round rather than sequentially.

For each catalog entry that is **not** marked `unpinned` and **not** excluded by the user:

Apply the **find-proper-software-version** skill, passing:

- Package name
- Variable name
- Current version
- Source type
- Any coordination context (e.g. target Go version when looking up Delve)

Process coordination-constrained pairs together:

- Look up `GO_VERSION` first; pass the result as context when looking up `DELVE_VERSION`.
- Look up `ARCHGATE_VERSION` and immediately retrieve the matching `ARCHGATE_GIT_SHA` in the same step (`npm view archgate@<version> gitHead`).

#### Source-type lookup guidance

| Source Type | Primary method | Notes |
|---|---|---|
| `github-release` / `go-module` | `gh release view --repo <owner>/<repo> <tag>` or `gh api repos/<owner>/<repo>/releases/latest` | Prefer `gh` over raw `curl` — authenticated, no rate limiting |
| `npm-package` | `npm view <pkg> version` | Returns the `latest` dist-tag |
| `npm-package` (multi-track) | `npm dist-tag ls <pkg>` | Use when a package has parallel major-version tracks (e.g. pnpm v11/v12). Pick the track that matches the currently pinned major. |
| `pypi-package` | `curl -s "https://pypi.org/pypi/<pkg>/json" \| python3 -c "import sys,json; print(json.load(sys.stdin)['info']['version'])"` | Used for packages installed via `uv tool install` or `pip` |
| `maven-central` | `curl -s "https://search.maven.org/solrsearch/select?q=g:<groupId>+AND+a:<artifactId>&rows=1&wt=json"` | Fall back to `maven-metadata.xml` if solrsearch returns a stale version |
| `debian-snapshot` | 1. `curl -s "https://snapshot.debian.org/archive/debian/?year=YYYY&month=MM"` to find the latest snapshot date. 2. Verify the tag exists on Docker Hub: `curl -s "https://hub.docker.com/v2/repositories/library/debian/tags/trixie-YYYYMMDD"` — if `"name"` is absent, the tag is not yet published. Fall back to the previous date. | Docker Hub publication lags behind `snapshot.debian.org` by several days. A snapshot existing on `snapshot.debian.org` does **not** mean `FROM debian:trixie-YYYYMMDD` will work. Always confirm on Docker Hub. |
| GCS / custom URL | Check the tool's auto-updater manifest endpoint (documented in the Dockerfile comment above the ENV block) | e.g. Antigravity CLI uses a GCS manifest URL |

#### Post-lookup verification for npm packages

After obtaining a proposed version for any `npm-package`, confirm it exists on the registry before adding it to the table:

```bash
npm view "<pkg>@<proposed-version>" version
```

If this returns an error or a different version, investigate before proceeding (the maintainer may have unpublished the version or the dist-tag may lag behind).

Collect all results into a version-update table:

```
| Variable | Current | Proposed | Change Level | Notes |
|---|---|---|---|---|
| GO_VERSION | 1.26.1 | 1.27.0 | minor | Update DELVE_VERSION together |
| ... | ... | ... | ... | ... |
```

When updating multiple files, add a **File** column and group rows by file, or annotate each row with the file(s) it affects.

### Phase 4: Security Verification

**CRITICAL**: Before presenting the version updates for approval, verify that none of the proposed updates introduce security risks.

**Parallelize aggressively**: batch the changed dependencies into groups and spawn multiple security-verification agents simultaneously.

Apply the **verify-dependency-security** skill to all dependencies with proposed version changes.

For each dependency, pass:

- Package name
- Current version
- Proposed version
- Source type
- Package URL (GitHub repo, npm registry, Maven Central, etc.)

The security verification will produce a risk assessment for each dependency, including:

- Known vulnerabilities (CVEs) in the proposed version
- Suspicious release patterns (supply-chain attack indicators)
- Trust signals (repository activity, community trust, maintainer history)

#### Known verification quirks

- **debian-snapshot**: `snapshot.debian.org` returns **HTTP 302** (redirect) for valid snapshot dates — this is normal. Follow the redirect with `curl -sL --head` and confirm the final response is **HTTP 200** before treating it as confirmed. However, a 200 from `snapshot.debian.org` is **not sufficient**: Docker Hub publishes `debian:trixie-YYYYMMDD` images with a lag of several days after the snapshot is created. Always separately verify that the Docker Hub tag exists before selecting the date — see the lookup table row for `debian-snapshot`.
- **npm packages with registry 403**: npmjs.com returns 403 on WebFetch for many packages. Fall back to `npm view <pkg>@<version> version` via Bash to confirm the version exists, and use WebSearch for maintainer / CVE information.
- **REVIEW due to stale search index**: a security agent may return REVIEW simply because a very recent release isn't yet indexed by search engines. Resolve by checking directly via `gh release view` or `npm view` and upgrading to APPROVE if no actual security concerns are found.

**If any dependency is flagged as High or Critical risk:**

1. Present the security report to the user immediately.
2. Ask whether to:
   - **Exclude** the high-risk dependency from the update (keep current version)
   - **Proceed anyway** (user accepts the risk)
   - **Cancel** the entire update operation

**If all dependencies are Low or Medium risk:**

- Include the security summary in the next phase (approval).
- Medium-risk dependencies should be highlighted for user awareness but do not block approval.

Do not proceed to Phase 5 if any Critical-risk dependency is included without explicit user override.

### Phase 5: Present Diff for Approval

Show the complete version-update table to the user. Highlight:

- **Security summary**: Count of dependencies by risk level (Low / Medium / High / Critical)
- Any **Medium-risk dependencies** (from Phase 4) — note these for user awareness
- Any **major** version bumps (highest change risk)
- Any entries where `Change Level: none` (already up to date)
- Any coordination pairs that will be updated together

Use your interactive confirmation capability to request explicit user approval before writing any files. The user may:

- Approve all changes
- Approve a subset (specify which variables to skip)
- Cancel entirely

Do not proceed to Phase 6 without explicit approval.

### Phase 6: Determine the Target Directory Name

Repeat this step for each Dockerfile being updated.

Derive the target directory name from the approved version updates:

- Extract the Go major.minor from the approved `GO_VERSION` (e.g. `1.27.1` → `go1.27`).
- Extract the Node.js major from the currently installed Node version. If Node's major is unchanged, keep the existing suffix (e.g. `node25`).
- Combine: `go<major.minor>-node<major>` (e.g. `go1.27-node25`).

For Dockerfiles that do not contain `GO_VERSION` (Node-only images), derive the directory name from the Node.js major alone (e.g. `node26`).

**If the resulting name matches the current directory name**, you will overwrite the existing Dockerfile.

**If the resulting name differs** (because a Go or Node.js major version changed), you will create a new directory. If that new directory already exists, append `-2` (or the next available suffix) and inform the user.

### Phase 7: Write the Updated Dockerfile(s)

For each Dockerfile being updated:

1. If creating a new directory (because a major version changed):

   ```bash
   mkdir -p vscode-devcontainer/versions/<new-dir-name>
   ```

2. Apply every approved version substitution using the Edit tool. Replace only the version strings — do not alter comments, structure, or formatting.

3. After all edits are applied, verify with a targeted `grep` that:
   - Every approved variable now contains the new version string.
   - No old version strings remain for approved variables.

   ```bash
   grep -n "OLD_VERSION_STRING" path/to/Dockerfile  # should return nothing
   ```

Report any discrepancies before continuing.

**Edit tool tips for multi-value ENV blocks**: when two or more variables in the same `ENV` block need updating, replace the entire block in a single Edit call to avoid repeated partial matches on adjacent lines.

### Phase 8: Summarize and Next Steps

Report:

- Updated Dockerfile path(s)
- Whether each file was overwritten or a new directory was created
- Count of versions updated vs. unchanged vs. skipped (across all files)
- **Security summary**: All dependencies passed security verification (or note any Medium-risk dependencies that were approved, and any CVE fixes included in the updates)
- Full version-update table with before/after values; when multiple files were updated, annotate each row with the affected file(s)

Remind the user of the required next steps:

1. **Build and smoke-test locally** for each updated Dockerfile:
   ```bash
   docker build vscode-devcontainer/versions/<target-dir-name>/
   ```
2. **Push a git tag** containing the image's `filter_ref` value (see `.github/workflows/main.yml`) to trigger CI.
3. **Update `.devcontainer/devcontainer.json`** if it references a specific image tag.

## Important Considerations

- **Version directory policy**: Overwrite the existing Dockerfile if Go/Node.js major versions remain unchanged. Create a new directory only when a major version changes (e.g., Go 1.26 → 1.27, or Node 25 → 26).
- **No silent changes**: Every version substitution must be shown to the user and approved in Phase 5 before Phase 7 begins.
- **Minimal diff**: Only change version strings. Preserve all comments, whitespace, and structure from the source Dockerfile.
- **Unpinned tools stay unpinned**: `gopls` and `goimports` use `@latest` by design. Do not pin them.
- **Coordination pairs**: `GO_VERSION`+`DELVE_VERSION` and `ARCHGATE_VERSION`+`ARCHGATE_GIT_SHA` must always be updated as a unit or not at all.
- **Multi-track npm packages**: some npm packages (e.g. pnpm) maintain parallel major-version tracks with separate dist-tags (`latest-11`, `latest-12`). Use `npm dist-tag ls <pkg>` to identify the correct track for the currently pinned major, and verify the proposed version exists with `npm view <pkg>@<version> version`.
- **Additional source types** beyond the core five: `pypi-package` (installed via `uv`/`pip`), `gcs-release` (binary distributed via Google Cloud Storage with a manifest URL). Treat these like `github-release` for security purposes — confirm the download URL and checksum from the official manifest before updating.
- **Parallelism**: Phases 3 and 4 involve many independent lookups. Use parallel agent spawning to complete all lookups in a single wall-clock round rather than one-by-one.
