---
name: verify-dependency-security
description: Verifies the security and trustworthiness of dependency version updates before they are applied. Searches for known vulnerabilities (CVEs), suspicious release patterns, and supply-chain attack indicators. Use when updating or adding dependencies to ensure no security risks are introduced.
---

# Verify Dependency Security

Given a list of dependency updates (package name, current version, proposed version, source type), this skill performs comprehensive security verification to detect supply-chain attack risks, known vulnerabilities, and suspicious release patterns.

## When to Use

- Before applying any dependency version updates (via `update-versions` command)
- Before adding a new software package (via `add-software` command)
- When auditing existing dependencies for security issues

## Instructions

### Step 1: Receive the Dependency List

The caller provides a list of dependencies to verify, each with:

- **Package name**: e.g., `golang`, `node`, `golangci-lint`, `flyway`
- **Current version**: the version currently in use
- **Proposed version**: the version to update to
- **Source type**: `go-module`, `npm-package`, `github-release`, `maven-central`, `debian-snapshot`
- **Package URL**: the primary repository or registry URL

### Step 2: Search for Known Vulnerabilities (CVEs)

For each dependency, search for known vulnerabilities in the proposed version:

| Source Type       | Vulnerability Database               | Query Pattern                                                   |
| ----------------- | ------------------------------------ | --------------------------------------------------------------- |
| `go-module`       | pkg.go.dev, GitHub Security Advisories | `site:pkg.go.dev "<module path>" vulnerabilities`               |
| `npm-package`     | npm audit, Snyk, GitHub Advisories   | `site:npmjs.com "<package>" security OR site:snyk.io "<package>"` |
| `github-release`  | GitHub Security Advisories, NVD      | `site:github.com "<owner>/<repo>" security advisories CVE`      |
| `maven-central`   | Sonatype OSS Index, NVD              | `"<groupId>:<artifactId>" CVE vulnerability`                    |
| `debian-snapshot` | Debian Security Tracker              | `site:security-tracker.debian.org "<package-name>"`             |

Use WebSearch to query the appropriate database. For each vulnerability found:

1. Record the CVE ID, severity (Critical, High, Medium, Low), and affected version range.
2. Determine if the **proposed version** is affected. If the proposed version is patched, note it.
3. If the current version is vulnerable but the proposed version is patched, mark this as a **security fix**.

### Step 3: Analyze Release History and Patterns

For each dependency, examine recent release activity to detect suspicious patterns:

Use WebSearch or WebFetch to access:

- GitHub releases page (for `github-release` and `go-module` from GitHub)
- npm registry page (for `npm-package`)
- Maven Central page (for `maven-central`)

Look for the following **red flags**:

1. **Sudden major version jump** without corresponding major feature changes (e.g., v1.2.3 → v5.0.0 with minimal changelog)
2. **Unusual release frequency** — multiple releases in a short time after long inactivity
3. **Change in maintainers** — new committers or npm package owners appearing suddenly
4. **Minimal or suspicious changelog** — vague descriptions like "bug fixes" or "updates" without detail
5. **Large diff in release size** — binary size increased significantly without explanation

For each red flag detected, record the specific concern and the evidence (commit SHA, release note URL, etc.).

### Step 4: Verify Package Integrity and Trust Signals

Check the following trust signals:

| Trust Signal              | What to Check                                                  | Good Sign                                      | Red Flag                                         |
| ------------------------- | -------------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------ |
| **Repository activity**   | Recent commits, PRs, issues                                    | Active development, responsive maintainers     | Abandoned repo, no recent activity               |
| **Community trust**       | GitHub stars, forks, npm weekly downloads                      | High stars/downloads, established project      | Low engagement, sudden spike in downloads        |
| **Maintainer history**    | Contributor list, commit history                               | Long-term contributors, consistent activity    | New or unknown contributors, single-maintainer   |
| **Official source**       | Is this the canonical repository?                              | Links from official docs match this repo       | Ambiguous or unofficial source                   |
| **Signed releases**       | Are releases signed? (GitHub releases, npm provenance)         | GPG/Sigstore signatures present                | Unsigned releases, no provenance                 |
| **Dependencies**          | Does the package have unexpected or suspicious dependencies?   | Minimal, well-known dependencies               | Many unknown deps, obfuscated code               |

Use WebSearch and WebFetch to gather this information.

### Step 5: Generate the Security Report

For each dependency, produce a structured security report:

```
Package:            <package name>
Current Version:    <current version>
Proposed Version:   <proposed version>
Source Type:        <source type>

--- Vulnerability Scan ---
CVEs Found:         <count>
  - <CVE-ID>: <severity> — <description> (Affected: <version range>)
  - ...
Proposed Version Affected: <Yes/No/Patched>

--- Release Pattern Analysis ---
Red Flags:          <count>
  - <flag description>: <evidence / URL>
  - ...

--- Trust Signals ---
Repository Activity:    <Active / Stale / Abandoned>
Community Trust:        <High / Medium / Low>
Maintainer History:     <Stable / New Contributors / Single Maintainer>
Release Signatures:     <Signed / Unsigned>
Dependencies:           <Clean / Suspicious>

--- Overall Risk Assessment ---
Risk Level:         <Low / Medium / High / Critical>
Recommendation:     <Approve / Review Carefully / Reject>
Notes:              <any additional context or caveats>
```

**Risk Level Decision Matrix:**

| Condition                                               | Risk Level  |
| ------------------------------------------------------- | ----------- |
| Critical CVE in proposed version                        | **Critical** |
| High CVE in proposed version + red flags                | **Critical** |
| 2+ red flags detected                                   | **High**     |
| 1 red flag + low trust signals                          | **High**     |
| Medium CVE in proposed version                          | **Medium**   |
| 1 red flag OR low trust signals                         | **Medium**   |
| No CVEs, no red flags, high trust signals               | **Low**      |
| Security fix (current version has CVE, proposed patched) | **Low** (note: security improvement) |

**Recommendation:**

- **Approve**: Risk Level = Low, no concerns
- **Review Carefully**: Risk Level = Medium, user should manually verify
- **Reject**: Risk Level = High or Critical, do not proceed without investigation

### Step 6: Return the Aggregated Report

After analyzing all dependencies, return:

1. **Summary**: Total dependencies analyzed, count by risk level
2. **High-Risk Dependencies**: List any dependencies with High or Critical risk
3. **Recommendations**: Overall recommendation (Approve All, Review Some, Reject Some)
4. **Individual Reports**: Full security report for each dependency

If **any dependency is Critical or High risk**, strongly recommend the user to investigate before proceeding.

## Common Issues

**CVE database not accessible**: Fall back to searching NVD (National Vulnerability Database) or using GitHub's security advisories API.

**Release history unavailable**: If the package has no GitHub repository, rely on the package registry's metadata (npm, Maven Central, etc.).

**Ambiguous trust signals**: When in doubt, err on the side of caution. Flag the dependency as Medium risk and recommend manual review.

**False positives**: Some packages may have low stars/downloads but are trustworthy (e.g., new projects, niche tools). Use judgment and cross-reference with official documentation.

## Example Workflow

Input:
```
Package: golangci-lint
Current: v1.50.0
Proposed: v1.61.0
Source: github-release
URL: https://github.com/golangci/golangci-lint
```

Output:
```
Package:            golangci-lint
Current Version:    v1.50.0
Proposed Version:   v1.61.0
Source Type:        github-release

--- Vulnerability Scan ---
CVEs Found:         0
Proposed Version Affected: No

--- Release Pattern Analysis ---
Red Flags:          0

--- Trust Signals ---
Repository Activity:    Active (last commit 2 days ago)
Community Trust:        High (15k stars, 1.5k forks, 500k+ weekly downloads via Go)
Maintainer History:     Stable (core team maintained since 2018)
Release Signatures:     Signed (GPG signatures present)
Dependencies:           Clean (standard Go tooling dependencies)

--- Overall Risk Assessment ---
Risk Level:         Low
Recommendation:     Approve
Notes:              Well-established linter with strong community trust and active maintenance.
```
