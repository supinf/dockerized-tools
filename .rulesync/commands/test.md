---
name: test
description: "Builds a vscode-devcontainer Dockerfile locally and runs smoke tests to verify that installed tools are present and working."
targets: ["*"]
claudecode:
  skills:
    - dockerfile-test
  allowed-tools: Read, Bash(docker build *), Bash(docker run *), Bash(docker rmi *), Bash(find *), Bash(ls *)
  disable-model-invocation: true
---

# Test Dockerfile

Builds a `vscode-devcontainer` Dockerfile locally and runs smoke tests on the resulting image. Reports which binaries pass or fail version checks.

## Procedure

### Phase 1: Identify the Dockerfile

1. If the user specified a path, use it. Otherwise, list available version directories:

   ```bash
   find vscode-devcontainer/versions -name "Dockerfile" | sort
   ```

   Present the list and ask the user to confirm which one to test.

2. Read the Dockerfile to identify which tools are installed and which binaries to verify.

### Phase 2: Build the Image

Apply the **dockerfile-test** skill's build procedure.

- Image tag: `devcontainer-test:local`
- Build context: the directory containing the Dockerfile

Present the full build log to the user. If the build fails, show the error output and stop — do not proceed to smoke testing.

### Phase 3: Run Smoke Tests

Apply the **dockerfile-test** skill's smoke test procedure.

Identify the canary binaries from the Dockerfile and run each with a version flag. If the user specified particular tools to verify (e.g. a newly added binary), include those explicitly alongside the standard canary set.

### Phase 4: Report Results

Apply the **dockerfile-test** skill's reporting format: a summary table with pass/fail status for each binary.

If all tests pass, confirm the image is ready and remind the user of next steps:

1. **Push a git tag** with the appropriate `filter_ref` (see `.github/workflows/main.yml`) to trigger CI.
2. **Update `.devcontainer/devcontainer.json`** if it references a specific image tag.

If any test fails, describe the failure, suggest likely root causes (refer to the Common Issues section in the dockerfile-test skill), and ask the user how to proceed.

### Phase 5: Cleanup (Optional)

Ask the user whether to remove the local test image to free disk space:

```bash
docker rmi devcontainer-test:local
```

## Important Considerations

- **Build failures take priority**: Never skip or ignore a build error. Report it fully and stop.
- **Docker daemon required**: The `docker` CLI must be available and the daemon must be running. If `docker build` fails with a connection error, report the prerequisite and stop.
- **Arch-specific testing**: By default, build for the host architecture. If the user wants to test cross-compilation, they can specify `--platform linux/amd64` or `--platform linux/arm64` — pass it through to the `docker build` command.
