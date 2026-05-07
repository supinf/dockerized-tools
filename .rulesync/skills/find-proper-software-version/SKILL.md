---
name: find-proper-software-version
description: Looks up the latest stable release for a single software package and returns the exact version string to pin in a Dockerfile. Use when you have a dependency name, its current version, and its source type (go-module, npm-package, github-release, maven-central, debian-snapshot) and need the correct new version string. Do not use for packages marked as unpinned or intentionally @latest.
---

# Find Proper Software Version

Given a package name, its current version, and its source type, searches authoritative sources and returns the latest stable version string ready to paste into a Dockerfile.

## Instructions

### Step 1: Direct API / CLI Lookup (Primary — Always Try First)

Use Bash commands to query authoritative sources directly. These are faster and more reliable than web searches, which frequently return stale data.

**npm-package:**
```bash
npm view <package-name> version
```
For scoped packages (e.g. `@google/gemini-cli`):
```bash
npm view "@google/gemini-cli" version
```

**github-release** and **go-module** (installed via `go install` from GitHub):
```bash
curl -s "https://api.github.com/repos/<owner>/<repo>/releases/latest" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tag_name','NOT FOUND'))"
```

**debian-snapshot** — find the latest available snapshot date for the `trixie` suite:
```bash
curl -s "https://snapshot.debian.org/archive/debian/?year=YYYY&month=MM" \
  | python3 -c "
import sys, re
dates = re.findall(r'(\d{8})T\d+Z', sys.stdin.read())
print('Latest:', max(dates) if dates else 'none found')
"
```
Use the current year and month. If no dates appear for the current month, try the previous month.

**maven-central:**
```bash
curl -s "https://search.maven.org/solrsearch/select?q=g:<groupId>+AND+a:<artifactId>&rows=1&wt=json&core=gav" \
  | python3 -c "import sys,json; docs=json.load(sys.stdin)['response']['docs']; print(docs[0]['v'] if docs else 'NOT FOUND')"
```

If the Bash tool is unavailable or the command fails, fall back to Step 2.

### Step 2: WebSearch Fallback

Use WebSearch only when direct API/CLI lookup is unavailable or fails. Note that search results are often stale by days or weeks — prefer the direct lookup whenever possible.

| Source Type       | Fallback Query Pattern                                     |
| ----------------- | ---------------------------------------------------------- |
| `go-module`       | `site:github.com "<owner>/<repo>" releases latest`        |
| `npm-package`     | `site:npmjs.com "<package name>" versions`                 |
| `github-release`  | `site:github.com "<owner>/<repo>" releases latest`        |
| `maven-central`   | `site:search.maven.org "<groupId>" "<artifactId>"`        |
| `debian-snapshot` | `snapshot.debian.org trixie YYYYMM latest snapshot`       |

### Step 3: Validate the Version

After obtaining a version string via either method:

1. **Reject** any version that contains: `-alpha`, `-beta`, `-rc`, `-pre`, `-dev`, or `.dev`.
2. If the latest tag is a pre-release, use the most recent **stable** tag instead.
3. Confirm the version is a proper release (not a draft or yanked).

For **npm packages**, the `version` field returned by `npm view` reflects the `latest` dist-tag, which is always the current stable release. No additional filtering is needed unless the package is known to publish preview builds to `latest`.

### Step 4: Verify the Version String Format

Match the format already used in the Dockerfile:

| Pattern                                              | Example           |
| ---------------------------------------------------- | ----------------- |
| `v`-prefixed semver (Go tools, most GitHub releases) | `v1.26.1`         |
| Bare semver (Flyway, npm tools)                      | `9.9.0`           |
| Debian dated snapshot                                | `trixie-YYYYMMDD` |

If the Dockerfile currently uses `v`-prefixed, return `v`-prefixed. Never change the format.

Note: the GitHub API returns tags exactly as published (e.g. `v1.26.3`). Use the tag as-is if it matches the Dockerfile's current format.

### Step 5: Handle Special Cases

**`gopls` and `goimports`** — installed with `@latest` intentionally.
Return: `SKIP — intentionally unpinned`

**`ARCHGATE_VERSION` + `ARCHGATE_GIT_SHA`** — these two must be updated together.
After finding the new `ARCHGATE_VERSION` via `npm view archgate version`, retrieve the SHA:
```bash
npm view "archgate@<new_version>" gitHead
```
Return both the version string and the corresponding SHA.

**`DELVE_VERSION`** — must match the Go major version. When called for Delve, also receive the target Go version as context. The Delve release tag must be `v<go-major>.<x>.<y>` — verify compatibility on the [Delve compatibility table](https://github.com/go-delve/delve/tree/master/Documentation/compatibility) if the Go major version changed.

**`DEBIAN_VERSION`** — query `snapshot.debian.org` directly (see Step 1). Return in the format `trixie-YYYYMMDD` using the latest available date.

**`openjdk-25-jdk-headless` (apt package)** — the package name encodes the major version. Do not change the major version number unless a newer JDK major is confirmed available in the Debian `trixie` repo. Return the package name as-is if no major version change is needed.

### Step 6: Return the Result

Return a single structured block:

```
Package:        <human-readable name>
Variable:       <ENV var name in Dockerfile>
Current:        <current version string>
Latest Stable:  <new version string>
Source URL:     <the specific page or release URL you used>
Lookup Method:  <direct-api | websearch>
Format:         <v-prefixed | bare | date>
Change Level:   <patch | minor | major | none>
Notes:          <any caveats, coordination requirements, or breaking change warnings>
```

If the current version is already the latest, set `Change Level: none` and explain.

## Common Issues

**WebSearch returns a version older than the currently pinned one**: This is a known issue — search indexes lag behind actual releases. Always verify using the direct API/CLI method. Do not downgrade a version based solely on stale search results.

**GitHub API rate limiting**: Unauthenticated requests are limited to 60/hour. If rate-limited, fall back to WebSearch. If a `GITHUB_TOKEN` environment variable is set, pass it via `-H "Authorization: token $GITHUB_TOKEN"`.

**Ambiguous latest**: Some projects maintain multiple stable branches (e.g. LTS vs. current). Default to the **current stable** branch unless the Dockerfile is already on an LTS line — in that case stay on the same LTS branch.

**Version behind a git tag vs. a semver release**: For `go install` packages, prefer the semver tag published on pkg.go.dev over raw git tags, as the former confirms the module is properly versioned.

**`npm view` returns an unexpected older version**: The `latest` dist-tag can occasionally be set to a lower version number than others published. If the currently pinned version is higher than what `npm view` returns, investigate before downgrading — the maintainer may have intentionally rolled back `latest`.
