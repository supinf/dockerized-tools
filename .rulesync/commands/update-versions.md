---
name: update-versions
description: "Updates all pinned dependency versions in a Dockerfile to their latest stable releases and writes the result into a new version directory. Runs analyze-dependencies and find-proper-software-version skills as sub-steps."
targets: ["*"]
claudecode:
  skills:
    - analyze-dependencies
    - find-proper-software-version
  allowed-tools: Read, Write, Edit, Bash(find *), Bash(ls *), Bash(bash .rulesync/rulesync.sh), WebSearch, WebFetch
  disable-model-invocation: true
---

# Update Dependency Versions

Brings every pinned dependency in a Dockerfile up to its latest stable release, then writes a new version directory. Because version directories are append-only, this command **always creates a new directory** — it never edits an existing Dockerfile.

## Procedure

### Phase 1: Identify the Target Dockerfile

1. If the user specified a path, use it. Otherwise, run:

   ```bash
   find vscode-devcontainer/versions -name "Dockerfile" | sort
   ```

   and present the list. Ask the user which version to base the update on, or confirm the most recent one.

2. Read the selected Dockerfile in full.

3. Note the current version directory name (e.g. `go1.26-node25`). The new directory will use updated major version numbers from `GO_VERSION` and the Node.js major in use.

### Phase 2: Analyze Dependencies

Apply the **analyze-dependencies** skill to the Dockerfile content.

Produce the full dependency catalog as specified by that skill, including:

- Variable name and current version
- Package / module identifier
- Source type
- Coordination warnings

Present the catalog to the user so they can review scope before any web searches begin. Ask for confirmation to proceed, or allow exclusions (e.g. "skip FLYWAY_VERSION").

### Phase 3: Research Latest Stable Versions

For each catalog entry that is **not** marked `unpinned` and **not** excluded by the user:

Apply the **find-proper-software-version** skill, passing:

- Package name
- Variable name
- Current version
- Source type
- Any coordination context (e.g. target Go version when looking up Delve)

Process coordination-constrained pairs together:

- Look up `GO_VERSION` first; pass the result as context when looking up `DELVE_VERSION`.
- Look up `ARCHGATE_VERSION` and immediately retrieve the matching `ARCHGATE_GIT_SHA` in the same step.

Collect all results into a version-update table:

```
| Variable | Current | Proposed | Change Level | Notes |
|---|---|---|---|---|
| GO_VERSION | 1.26.1 | 1.27.0 | minor | Update DELVE_VERSION together |
| ... | ... | ... | ... | ... |
```

### Phase 4: Present Diff for Approval

Show the complete version-update table to the user. Highlight:

- Any **major** version bumps (highest risk)
- Any entries where `Change Level: none` (already up to date)
- Any coordination pairs that will be updated together

Use your interactive confirmation capability to request explicit user approval before writing any files. The user may:

- Approve all changes
- Approve a subset (specify which variables to skip)
- Cancel entirely

Do not proceed to Phase 5 without explicit approval.

### Phase 5: Determine the New Version Directory Name

Derive the new directory name from the approved version updates:

- Extract the Go major.minor from the approved `GO_VERSION` (e.g. `1.27.1` → `go1.27`).
- Extract the Node.js major from the currently installed Node version. If Node's major is unchanged, keep the existing suffix (e.g. `node25`).
- Combine: `go<major.minor>-node<major>` (e.g. `go1.27-node25`).

If the resulting name already exists as a directory, append `-2` (or the next available suffix) and inform the user.

### Phase 6: Write the New Dockerfile

1. Create the new directory:

   ```bash
   mkdir -p vscode-devcontainer/versions/<new-dir-name>
   ```

2. Copy the source Dockerfile content, applying every approved version substitution. Replace only the version strings — do not alter comments, structure, or formatting.

3. Write the result to `vscode-devcontainer/versions/<new-dir-name>/Dockerfile`.

4. Re-read the written file and verify that:
   - Every approved variable now contains the new version string.
   - No old version strings remain for approved variables.
   - The file is otherwise identical to the source.

Report any discrepancies before continuing.

### Phase 7: Summarize and Next Steps

Report:

- New Dockerfile path
- Count of versions updated vs. unchanged vs. skipped
- Full version-update table with before/after values

Remind the user of the required next steps:

1. **Build and smoke-test locally**: `docker build vscode-devcontainer/versions/<new-dir-name>/`
2. **Push a git tag** containing the image's `filter_ref` value (see `.github/workflows/main.yml`) to trigger CI.
3. **Update `.devcontainer/devcontainer.json`** if it references a specific image tag.

## Important Considerations

- **Append-only**: Never edit any file under an existing `versions/<tag>/` directory. Always write to a new directory.
- **No silent changes**: Every version substitution must be shown to the user and approved in Phase 4 before Phase 6 begins.
- **Minimal diff**: Only change version strings. Preserve all comments, whitespace, and structure from the source Dockerfile.
- **Unpinned tools stay unpinned**: `gopls` and `goimports` use `@latest` by design. Do not pin them.
- **Coordination pairs**: `GO_VERSION`+`DELVE_VERSION` and `ARCHGATE_VERSION`+`ARCHGATE_GIT_SHA` must always be updated as a unit or not at all.
