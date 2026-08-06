# syntax=docker/dockerfile:1

# ==============================================================================
# Global Arguments
# ==============================================================================
ARG DEBIAN_VERSION=trixie-20260803

# ==============================================================================
# Development Environment
# ==============================================================================
FROM debian:${DEBIAN_VERSION}

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt/archives,id=apt-archives-${TARGETARCH} \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    make \
    curl \
    wget \
    unzip \
    ca-certificates \
    openssh-client \
    jq \
    less \
    python3 \
    python3-pip \
    protobuf-compiler \
    libprotobuf-dev \
    gnupg lsb-release \
    postgresql-client \
    xz-utils \
    locales \
    lsof iproute2 \
    && localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# gcloud
# ------------------------------------------------------------------------------
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
RUN apt-get update && apt-get install -y google-cloud-cli

# ------------------------------------------------------------------------------
# GitHub CLI (gh)
# ------------------------------------------------------------------------------
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && apt install -y gh && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# Python Tools (uv など)
# ------------------------------------------------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH=/root/.local/bin:$PATH \
    CHECKOV_VERSION=3.3.9

RUN uv tool install "checkov==${CHECKOV_VERSION}"

# ------------------------------------------------------------------------------
# Node.js Tools (pnpm, rulesync など)
# ------------------------------------------------------------------------------
ENV NPM_VERSION=12.0.2 \
    PNPM_VERSION=11.20.0 \
    RULESYNC_VERSION=16.7.0

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs

RUN --mount=type=cache,target=/root/.npm \
    npm install -g "npm@${NPM_VERSION}" --force && \
    npm install -g "pnpm@${PNPM_VERSION}" && \
    npm install -g "rulesync@${RULESYNC_VERSION}" && \
    npm cache clean --force

# ------------------------------------------------------------------------------
# Playwright CLI
# ------------------------------------------------------------------------------
ENV PLAYWRIGHT_CLI_VERSION=0.1.17

RUN --mount=type=cache,target=/root/.npm \
    npm install -g "@playwright/cli@${PLAYWRIGHT_CLI_VERSION}" && \
    npm cache clean --force

# ------------------------------------------------------------------------------
# AWS CLI v2
# ------------------------------------------------------------------------------
RUN case ${TARGETARCH} in \
         "amd64")  AWS_ARCH="x86_64"  ;; \
         "arm64")  AWS_ARCH="aarch64" ;; \
         *)        echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -f awscliv2.zip \
    && rm -rf aws

# ------------------------------------------------------------------------------
# Claude Code
# ------------------------------------------------------------------------------
ENV ANTHROPIC_MODEL=claude-sonnet-5@default \
    ANTHROPIC_SMALL_FAST_MODEL=claude-haiku-4-5@20251001

RUN npm install -g "@anthropic-ai/claude-code" && \
    npm cache clean --force

# ------------------------------------------------------------------------------
# Codex
# ------------------------------------------------------------------------------
ENV CODEX_CLI_VERSION=0.146.1 \
    CODEX_HOME=/root/.codex \
    OPENAI_BASE_URL=https://api.openai.com/v1 \
    CODEX_MODEL=gpt-5.3-codex

RUN --mount=type=cache,target=/root/.npm \
    npm install -g "@openai/codex@${CODEX_CLI_VERSION}" && \
    npm cache clean --force

# ------------------------------------------------------------------------------
# Antigravity
# ------------------------------------------------------------------------------
# ANTIGRAVITY_AMD64_URL / ANTIGRAVITY_ARM64_URL: The fixed version URL for GCS.
# ANTIGRAVITY_AMD64_SHA512 / ANTIGRAVITY_ARM64_SHA512: SHA512 checksum.
# When updating the version: Check the latest manifest at https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_{amd64,arm64}.json and update.
ENV GOOGLE_CLOUD_LOCATION=global \
    GOOGLE_GENAI_USE_VERTEXAI=true \
    ANTIGRAVITY_VERSION=1.1.10 \
    ANTIGRAVITY_AMD64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.10-6423386432339968/linux-x64/cli_linux_x64.tar.gz \
    ANTIGRAVITY_AMD64_SHA512=e64d4e58ede0f8440f2b3dc021f9d6d36b05f5c2f74d5a9215c1f11b20d536c8c2e020f4ce5257aa67e940e94c94d5a16d3aa6461cda18ee7f3e74d3a20ca1ac \
    ANTIGRAVITY_ARM64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.10-6423386432339968/linux-arm/cli_linux_arm64.tar.gz \
    ANTIGRAVITY_ARM64_SHA512=2d64c4e09eb22c824bc298ca61e48cb0e62688353db4122996b2e4bba8c9a1570d2cbf6e6452ed7ef30df0940bf8f058789e466aed5264c1ae2e4613eca5b573

RUN case ${TARGETARCH} in \
         "amd64") AGY_URL="${ANTIGRAVITY_AMD64_URL}"; AGY_SHA512="${ANTIGRAVITY_AMD64_SHA512}" ;; \
         "arm64") AGY_URL="${ANTIGRAVITY_ARM64_URL}"; AGY_SHA512="${ANTIGRAVITY_ARM64_SHA512}" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "${AGY_URL}" -o /tmp/antigravity.tar.gz && \
    echo "${AGY_SHA512}  /tmp/antigravity.tar.gz" | sha512sum -c - && \
    tar -xzf /tmp/antigravity.tar.gz -C /tmp antigravity && \
    mv /tmp/antigravity /usr/local/bin/agy && \
    chmod +x /usr/local/bin/agy && \
    rm /tmp/antigravity.tar.gz && \
    agy install --dir /usr/local/bin || true

# ------------------------------------------------------------------------------
# Archgate
# ------------------------------------------------------------------------------
# ARCHGATE_GIT_SHA: the git commit SHA corresponding to ARCHGATE_VERSION.
# Update both together when bumping the version.
# To find the SHA: npm view archgate@<version> gitHead
ENV ARCHGATE_VERSION=0.51.0 \
    ARCHGATE_GIT_SHA=0dbc4b35e881de86950d98d1355fffed43374a7e \
    ARCHGATE_TELEMETRY=0

RUN if [ "$TARGETARCH" = "arm64" ]; then \
    # arm64: pre-built archgate binary not available — build from source using Bun \
    curl -fsSL https://bun.sh/install | BUN_INSTALL=/tmp/bun bash && \
    git clone https://github.com/archgate/cli.git /tmp/archgate-src && \
    git -C /tmp/archgate-src checkout "${ARCHGATE_GIT_SHA}" && \
    /tmp/bun/bin/bun install --cwd /tmp/archgate-src && \
    /tmp/bun/bin/bun build /tmp/archgate-src/src/cli.ts \
        --compile --bytecode --target=bun-linux-arm64 \
        --outfile /usr/local/bin/archgate && \
    rm -rf /tmp/archgate-src /tmp/bun; \
  else \
    npm install -g "archgate@${ARCHGATE_VERSION}" && npm cache clean --force; \
  fi

# ------------------------------------------------------------------------------
# Gitleaks
# ------------------------------------------------------------------------------
# GITLEAKS_SHA256_*: from https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_checksums.txt
ENV GITLEAKS_VERSION=8.30.1 \
    GITLEAKS_SHA256_X64=551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb \
    GITLEAKS_SHA256_ARM64=e4a487ee7ccd7d3a7f7ec08657610aa3606637dab924210b3aee62570fb4b080

RUN case ${TARGETARCH} in \
         "amd64") GITLEAKS_ARCH="x64"; GITLEAKS_SHA256="${GITLEAKS_SHA256_X64}" ;; \
         "arm64") GITLEAKS_ARCH="arm64"; GITLEAKS_SHA256="${GITLEAKS_SHA256_ARM64}" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GITLEAKS_ARCH}.tar.gz" -o gitleaks.tar.gz && \
    echo "${GITLEAKS_SHA256}  gitleaks.tar.gz" | sha256sum -c - && \
    tar -xzf gitleaks.tar.gz -C /usr/local/bin gitleaks && \
    rm gitleaks.tar.gz

# ------------------------------------------------------------------------------
# Lefthook
# ------------------------------------------------------------------------------
# LEFTHOOK_SHA256_*: from https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_checksums.txt
ENV LEFTHOOK_VERSION=2.1.10 \
    LEFTHOOK_SHA256_X86_64=0b14162a0bb2f0c64ae0759f6102f6e19c4d00981666a8ac73d4f5a6878ada4f \
    LEFTHOOK_SHA256_ARM64=eb8a46b95a8405178b3eb55886225b107cbf65b6d7bd1b141cfa642c57bdc100

RUN case ${TARGETARCH} in \
         "amd64") LEFTHOOK_ARCH="x86_64"; LEFTHOOK_SHA256="${LEFTHOOK_SHA256_X86_64}" ;; \
         "arm64") LEFTHOOK_ARCH="arm64"; LEFTHOOK_SHA256="${LEFTHOOK_SHA256_ARM64}" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_Linux_${LEFTHOOK_ARCH}.gz" -o /tmp/lefthook.gz && \
    echo "${LEFTHOOK_SHA256}  /tmp/lefthook.gz" | sha256sum -c - && \
    gunzip -c /tmp/lefthook.gz > /usr/local/bin/lefthook && \
    rm /tmp/lefthook.gz && \
    chmod +x /usr/local/bin/lefthook

# ------------------------------------------------------------------------------
# ShellCheck
# ------------------------------------------------------------------------------
ENV SHELLCHECK_VERSION=0.11.0

RUN case ${TARGETARCH} in \
         "amd64") SHELLCHECK_ARCH="x86_64"  ;; \
         "arm64") SHELLCHECK_ARCH="aarch64" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${SHELLCHECK_ARCH}.tar.xz" -o shellcheck.tar.xz && \
    tar -xJf shellcheck.tar.xz --strip-components=1 -C /usr/local/bin "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" && \
    rm shellcheck.tar.xz

ENTRYPOINT [ "sleep", "infinity" ]
