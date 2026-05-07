---
name: verify-dependency-security
description: Verifies a dependency update for supply chain attack indicators before applying version changes. Checks package ownership, release authenticity, known vulnerabilities, and suspicious patterns.
---

# Verify Dependency Security

Performs a security assessment of a dependency version update before approval.

## Input Parameters

This skill expects the following inputs:

- **Package name**: The human-readable name of the dependency (e.g., `golangci-lint`, `typescript`, `aws-cli`)
- **Current version**: The currently pinned version string, or `(none — new addition)` for new packages
- **Proposed version**: The target version to verify
- **Source type**: One of: `npm-package`, `github-release`, `python-package`, `debian-snapshot`, `go-module`, `maven-central`
- **Package URL**: The official repository or registry URL (e.g., `https://github.com/golangci/golangci-lint`, `https://www.npmjs.com/package/typescript`)

## Instructions

### Step 1: Verify Package Registry Authenticity

Check the official registry based on source type.

**For npm-package:**

```
WebFetch: https://www.npmjs.com/package/<package-name>
Prompt: "Extract: 1) Current maintainers list, 2) Weekly download count, 3) Latest published version, 4) Repository URL. List only the facts."
```

**For github-release:**

```
WebFetch: https://github.com/<owner>/<repo>/releases/tag/<version>
Prompt: "Extract: 1) Release author username, 2) Is release signed (look for GPG signature or checksum files), 3) Release date, 4) Asset file names and sizes. List only the facts."
```

**For python-package:**

```
WebFetch: https://pypi.org/project/<package-name>/<version>/
Prompt: "Extract: 1) Maintainers, 2) Release date, 3) File hashes present (yes/no), 4) Project links. List only the facts."
```

**For debian-snapshot:**

```
WebSearch: site:snapshot.debian.org <suite> <YYYYMMDD>
```

Confirm the snapshot date exists in the official Debian archive.

**For go-module:**

```
WebFetch: https://pkg.go.dev/<module-path>@<version>
Prompt: "Extract: 1) Module path, 2) Published date, 3) Repository link, 4) License. List only the facts."
```

Also check the GitHub repository if available:

```
WebFetch: https://github.com/<owner>/<repo>/releases/tag/<version>
Prompt: "Extract: 1) Release author, 2) Commit SHA, 3) Release date. List only the facts."
```

**For maven-central:**

```
WebFetch: https://central.sonatype.com/artifact/<group-id>/<artifact-id>/<version>
Prompt: "Extract: 1) Group ID, 2) Artifact ID, 3) Version, 4) Published date, 5) Repository URL. List only the facts."
```

### Step 2: Check for Known Vulnerabilities

Search CVE databases and security advisories.

```
WebSearch: "<package-name>" "<proposed-version>" CVE vulnerability security advisory 2026
```

From search results, identify:
- HIGH or CRITICAL severity CVEs
- Security advisories recommending against this version
- Known compromised releases

### Step 3: Cross-Reference Community Reports

Check for community reports and discussions (recommended for critical packages).

```
WebSearch: "<package-name>" "<version>" malicious supply chain attack 2026
```

Look for suspicious patterns such as sudden maintainer changes or re-publication after deletion.

### Step 4: Return Structured Assessment

Return the assessment in this format:

```
Package:         <human-readable name>
Current Version: <current>
Proposed Version: <proposed>
Source Type:     <npm-package | github-release | python-package | debian-snapshot | go-module | maven-central>
Package URL:     <official repository or registry URL>

--- Registry Verification ---
Status:          PASS | WARN | FAIL
Details:         <What you found: maintainers, signatures, download patterns>
Concerns:        <List any red flags, or "None">

--- Vulnerability Check ---
Status:          PASS | WARN | FAIL
Known CVEs:      <Number and severity, or "None found">
Advisories:      <Summary of any security advisories>
Concerns:        <List any issues, or "None">

--- Community/Pattern Check ---
Status:          PASS | WARN | FAIL
Findings:        <Summary of community reports or suspicious patterns>
Concerns:        <List any red flags, or "None">

--- RECOMMENDATION ---
Decision:        APPROVE | REVIEW | REJECT
Risk Level:      Low | Medium | High | Critical
Reason:          <1-2 sentence explanation>
Action Required: <What the user should do, or "None - proceed with update">
```

## Status Definitions

- **PASS**: Check completed, no concerns detected
- **WARN**: Minor concerns present, user review recommended
- **FAIL**: Significant risk detected, update not recommended

## Recommendation Guidelines

- **APPROVE**: All checks PASS, or only minor WARNs with clear explanations
- **REVIEW**: One or more WARN flags requiring user evaluation
- **REJECT**: Any FAIL status, or multiple significant WARNs

## Risk Level Mapping

For integration with workflows that expect risk levels, map the recommendation to these categories:

- **Low**: Decision is APPROVE with all checks PASS
- **Medium**: Decision is APPROVE or REVIEW with one or more WARN status
- **High**: Decision is REVIEW with multiple WARN status, or REJECT with one FAIL
- **Critical**: Decision is REJECT with multiple FAIL status or known high-severity CVEs

## Important Notes

- If registry information cannot be fetched, note this explicitly and mark as WARN
- New maintainers or repository transfers can be legitimate — provide context, not just flags
- Apply stricter standards to critical packages (AWS CLI, GitHub CLI, Docker, Kubernetes tools, etc.)
- When in doubt, recommend REVIEW and let the user decide with full information
- For go-module packages, verify both pkg.go.dev and the upstream GitHub repository when available
- For maven-central packages, verify the artifact exists on Maven Central and check the linked repository
- **Always include Risk Level** in the final recommendation to support workflow integration
