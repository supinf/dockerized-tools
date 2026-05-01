---
name: find-proper-software-version
description: Looks up the latest stable release for a single software package and returns the exact version string to pin in a Dockerfile. Use when you have a dependency name, its current version, and its source type (go-module, npm-package, github-release, maven-central, debian-snapshot) and need the correct new version string. Do not use for packages marked as unpinned or intentionally @latest.
---

# Find Proper Software Version

Given a package name, its current version, and its source type, searches authoritative sources and returns the latest stable version string ready to paste into a Dockerfile.

## Instructions

### Step 1: Select the Lookup Strategy

Choose the search approach based on source type:

| Source Type       | Primary Lookup                | Query Pattern                                      |
| ----------------- | ----------------------------- | -------------------------------------------------- |
| `go-module`       | pkg.go.dev or GitHub releases | `"<module path>" latest release`                   |
| `npm-package`     | npmjs.com                     | `site:npmjs.com "<package name>" versions`         |
| `github-release`  | GitHub releases page          | `site:github.com "<owner>/<repo>" releases latest` |
| `maven-central`   | search.maven.org              | `site:search.maven.org "<groupId>" "<artifactId>"` |
| `debian-snapshot` | snapshot.debian.org           | `site:snapshot.debian.org trixie latest snapshot`  |

### Step 2: Search and Validate the Version

Use WebSearch with the query above. Then:

1. Identify the most recent release tag.
2. **Reject** any version that contains: `-alpha`, `-beta`, `-rc`, `-pre`, `-dev`, or `.dev`.
3. If the latest tag is a pre-release, use the most recent **stable** tag instead.
4. Confirm the version is a proper release (not a draft or yanked).

### Step 3: Verify the Version String Format

Match the format already used in the Dockerfile:

| Pattern                                              | Example           |
| ---------------------------------------------------- | ----------------- |
| `v`-prefixed semver (Go tools, most GitHub releases) | `v1.26.1`         |
| Bare semver (Flyway, npm tools)                      | `9.9.0`           |
| Debian dated snapshot                                | `trixie-YYYYMMDD` |

If the Dockerfile currently uses `v`-prefixed, return `v`-prefixed. Never change the format.

### Step 4: Handle Special Cases

**`gopls` and `goimports`** — installed with `@latest` intentionally.  
Return: `SKIP — intentionally unpinned`

**`ARCHGATE_VERSION` + `ARCHGATE_GIT_SHA`** — these two must be updated together.  
After finding the new `ARCHGATE_VERSION`, run:

```
WebSearch: npm view archgate@<new_version> gitHead
```

Return both the version string and the corresponding SHA.

**`DELVE_VERSION`** — must match the Go major version. When called for Delve, also receive the target Go version as context. The Delve release tag must be `v<go-major>.<x>.<y>` — verify compatibility on the [Delve compatibility table](https://github.com/go-delve/delve/tree/master/Documentation/compatibility) if the Go major version changed.

**`DEBIAN_VERSION`** — for a dated Debian snapshot, search for the latest snapshot date available for the `trixie` suite at `https://snapshot.debian.org/`. Return in the format `trixie-YYYYMMDD`.

**`openjdk-25-jdk-headless` (apt package)** — the package name encodes the major version. Do not change the major version number unless a newer JDK major is confirmed available in the Debian `trixie` repo. Return the package name as-is if no major version change is needed.

### Step 5: Return the Result

Return a single structured block:

```
Package:        <human-readable name>
Variable:       <ENV var name in Dockerfile>
Current:        <current version string>
Latest Stable:  <new version string>
Source URL:     <the specific page or release URL you used>
Format:         <v-prefixed | bare | date>
Change Level:   <patch | minor | major | none>
Notes:          <any caveats, coordination requirements, or breaking change warnings>
```

If the current version is already the latest, set `Change Level: none` and explain.

## Common Issues

**Version not found via WebSearch**: Fall back to fetching the GitHub releases page or npm registry directly with WebFetch. Prefer the official release page over aggregator sites.

**Ambiguous latest**: Some projects maintain multiple stable branches (e.g. LTS vs. current). Default to the **current stable** branch unless the Dockerfile is already on an LTS line — in that case stay on the same LTS branch.

**Version behind a git tag vs. a semver release**: For `go install` packages, prefer the semver tag published on pkg.go.dev over raw git tags, as the former confirms the module is properly versioned.
