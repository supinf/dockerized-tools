---
name: update-rules
description: "Update rule and command documentation based on recent changes."
targets: ["*"]
claudecode:
  allowed-tools: Read, Edit, Bash(git log *), Bash(git diff *), WebSearch
  disable-model-invocation: true
---

# Update Rules and Commands Documentation

This command facilitates the periodic review and update of documentation files located under `/.rulesync/commands/**`, `/.rulesync/rules/**`, `/.rulesync/skills/**` and `/.rulesync/subagents/**`. The goal is to ensure these documents accurately reflect the latest implementation status, remove misleading or outdated information, and incorporate essential new details.

## Procedure for AI Agent

To perform this task, follow these detailed steps:

1.  **Review Recent Git Logs**:
    - Execute `git log --since="1 week ago" --name-only --pretty=format:"%h - %an, %ar : %s"` to retrieve recent commits and associated file changes.
    - Identify changes relevant to documentation files in `/.rulesync/commands/`, `/.rulesync/rules/**`, `/.rulesync/skills/**` and `/.rulesync/rules/`.

2.  **Read Relevant Documentation Files**:
    - Identify all markdown files within `/.rulesync/commands/`, `/.rulesync/rules/**`, `/.rulesync/skills/**` and `/.rulesync/rules/`.
    - Use the `Read` tool to load the content of each identified file.

3.  **Analyze and Identify Necessary Changes**:
    - Compare the content of the read documentation files with the information extracted from the git logs.
    - Pinpoint sections that are outdated, inaccurate, or missing new, essential details.
    - Formulate precise, minimal updates that adhere to project conventions (e.g., using English and code only).

4.  **Propose Changes to the User**:
    - **Before making any modifications**, explain the rationale for the proposed changes to the user.
    - Clearly state:
      - Why the change is needed (e.g., to reflect a new feature, fix an outdated description, add a best practice).
      - Which specific document and section will be affected.
      - The exact `old_string` and `new_string` for the `replace` operation, including sufficient surrounding context.
    - Use your interactive confirmation capability to request explicit user approval before proceeding.

5.  **Execute Changes**:
    - Upon user approval, use the `Edit` tool to apply the modifications to each documentation file.
    - Ensure the change is clear and concise, explaining the purpose of the change.

6.  **Verify Updates (Optional but Recommended)**:
    - After changes, re-read the modified file(s) to confirm that the updates have been correctly applied.

## Important Considerations

- **Minimal Changes**: Always prioritize making the smallest possible change to achieve the desired clarity and accuracy.
- **Language**: All document prose in `.rulesync/` must be in **clear, complete English**. Code examples may use the project's designated comment language, but no Japanese should appear in prose or instructions.
- **User Communication**: Maintain clear and transparent communication with the user throughout the process, especially when proposing modifications.
- **No Assumptions**: Do not make assumptions about existing content; always read the file before attempting a `replace` operation.

## Structural Health Checklist

When reviewing `.rulesync/commands/` and `.rulesync/subagents/`, verify these structural properties in addition to content accuracy.

### Commands (`.rulesync/commands/`)

- [ ] Commands that invoke `Edit`, `Write`, or `Bash` (i.e., modify files or run code) have `claudecode: disable-model-invocation: true` set in frontmatter. This prevents the agent from auto-triggering destructive workflows without explicit user intent.
- [ ] Skill files (`.rulesync/skills/`) do **not** have `disable-model-invocation: true`. Setting this on a skill breaks any CLAUDE.md instruction that tells Claude to auto-load that skill.
- [ ] Phase gate language in command bodies uses agent-agnostic phrasing — for example, "use your interactive confirmation capability to request explicit user approval" — rather than naming a specific tool (e.g., `AskUserQuestion`). This ensures compatibility with agents other than Claude Code (Cursor, Roo, Gemini CLI, etc.).

### Subagents (`.rulesync/subagents/`)

- [ ] Subagents that require domain-specific patterns have `claudecode: skills:` set in their frontmatter. This pre-injects skill content into the subagent's context at startup, which is more reliable than instructing the subagent to read skill files manually at runtime.
- [ ] The `claudecode: skills:` list only includes skills that are directly needed by that subagent's role. Avoid over-loading context with irrelevant skills.
- [ ] Subagents do **not** contain instructions like "always read this skill file using the Read tool" when the skill is already listed in `claudecode: skills:`. These two approaches are mutually exclusive; the frontmatter field is preferred.

### General

- [ ] All document prose is in clear, unambiguous English. Do not use tool-specific terminology from any single agent in the shared document body.
- [ ] Agent-specific configuration belongs in the `claudecode:` (or equivalent) frontmatter namespace — not in the shared markdown body.
- [ ] If a command or subagent's behavior has changed, verify the compiled output in `.claude/` matches expectations by running `bash .rulesync/rulesync.sh` after editing source files.
