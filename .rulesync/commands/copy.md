---
name: copy
description: "Creates a new Dockerfile by copying an existing one and applying user-specified modifications. Follows append-only versioning: always writes to a new version directory."
targets: ["*"]
claudecode:
  skills:
    - dockerfile-authoring
  allowed-tools: Read, Write, Edit, Bash(find *), Bash(ls *), Bash(mkdir *)
  disable-model-invocation: true
---

# Copy Dockerfile

Creates a new Dockerfile based on an existing one, applying modifications as instructed by the user. Always writes to a **new version directory** — the source Dockerfile is never modified.

## Procedure

### Phase 1: Identify Source and Destination

1. Ask the user (or read from their message) for:
   - **Source**: path to the Dockerfile to copy from
   - **Destination**: target version directory name (e.g. `vscode-devcontainer/versions/go1.27-node25`)
   - **Modifications**: what changes to apply (may be none — a pure copy)

2. If the user did not specify a source, list available Dockerfiles:

   ```bash
   find vscode-devcontainer/versions -name "Dockerfile" | sort
   ```

   Present the list and ask the user to confirm which one to use as the base.

3. If the destination directory already exists, warn the user — do not proceed without their explicit confirmation.

4. Read the source Dockerfile in full.

### Phase 2: Plan the Modifications

Apply the **dockerfile-authoring** skill to understand the source Dockerfile structure.

Summarize the planned changes:

- What will be copied verbatim
- What will be changed, and why
- Any structural adjustments needed (e.g. new ENV variables, stage changes)

Use your interactive confirmation capability to request explicit user approval before writing any files.

### Phase 3: Write the New Dockerfile

1. Create the destination directory:

   ```bash
   mkdir -p <destination-dir>
   ```

2. Apply the approved modifications to the source content and write the result to `<destination-dir>/Dockerfile`.

3. Re-read the written file and verify the changes are correctly applied. Report any discrepancies.

### Phase 4: Report

- New Dockerfile path
- Summary of changes made vs. copied verbatim

Remind the user of next steps:

1. **Build and smoke-test**: use the `test` command or run `docker build <destination-dir>/`.
2. **Push a git tag** with the appropriate `filter_ref` to trigger CI (see `.github/workflows/main.yml`).

## Important Considerations

- **Append-only**: Never modify the source Dockerfile. Always write to a new directory.
- **Minimal diff**: Only apply the changes requested by the user. Preserve all comments, whitespace, and structure from the source.
- **Confirm before write**: Always show the planned changes to the user and get explicit approval before writing files.
