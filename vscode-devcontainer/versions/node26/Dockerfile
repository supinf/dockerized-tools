# syntax=docker/dockerfile:1

# ==============================================================================
# Global Arguments
# ==============================================================================
ARG DEBIAN_VERSION=trixie-20260713

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
    CHECKOV_VERSION=3.3.8

RUN uv tool install "checkov==${CHECKOV_VERSION}"

# ------------------------------------------------------------------------------
# Node.js Tools (pnpm, rulesync など)
# ------------------------------------------------------------------------------
ENV NPM_VERSION=12.0.1 \
    PNPM_VERSION=11.15.0 \
    RULESYNC_VERSION=14.0.1

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
ENV AWS_REGION=ap-northeast-1 \
    CLOUD_ML_REGION=global \
    ANTHROPIC_MODEL=claude-sonnet-5@default \
    ANTHROPIC_SMALL_FAST_MODEL=claude-haiku-4-5@20251001

# ------------------------------------------------------------------------------
# Cline
# ------------------------------------------------------------------------------
ENV CLINE_AWS_REGION=ap-northeast-1 \
    CLINE_BEDROCK_MODEL_ID=global.anthropic.claude-sonnet-5 \
    CLINE_VERTEX_REGION=global \
    CLINE_VERTEX_MODEL_ID=claude-sonnet-5@default \
    CLINE_OPENAI_BASE_URL=https://api.openai.com/v1 \
    CLINE_OPENAI_MODEL=gpt-5.3-codex

# ------------------------------------------------------------------------------
# Codex
# ------------------------------------------------------------------------------
ENV CODEX_CLI_VERSION=0.144.6 \
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
    ANTIGRAVITY_VERSION=1.1.4 \
    ANTIGRAVITY_AMD64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.4-6277569641840640/linux-x64/cli_linux_x64.tar.gz \
    ANTIGRAVITY_AMD64_SHA512=a088a1f231d8565b6673cecd8656fc3504e49c89e9c6b8c4116937b5fe7069c8dcfba78bbb2bc5c0ff8e87ba64fe21b63db7001e3a5794504927dad9e89da973 \
    ANTIGRAVITY_ARM64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.4-6277569641840640/linux-arm/cli_linux_arm64.tar.gz \
    ANTIGRAVITY_ARM64_SHA512=8d3c464303b235b6f2c2d441eca07b0c1cc35efa68f7ae16b167a5a2d49373903efdf686b3e41063424f0cf0c5b5d5eb056f7944dade7abf1b8eb225cb8c438c

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
ENV ARCHGATE_VERSION=0.50.0 \
    ARCHGATE_GIT_SHA=cd63671b590aa923b805eeee12fd3380e152a0ff \
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
ENV GITLEAKS_VERSION=8.30.1

RUN case ${TARGETARCH} in \
         "amd64") GITLEAKS_ARCH="x64"  ;; \
         "arm64") GITLEAKS_ARCH="arm64" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GITLEAKS_ARCH}.tar.gz" -o gitleaks.tar.gz && \
    tar -xzf gitleaks.tar.gz -C /usr/local/bin gitleaks && \
    rm gitleaks.tar.gz

# ------------------------------------------------------------------------------
# Lefthook
# ------------------------------------------------------------------------------
ENV LEFTHOOK_VERSION=2.1.10

RUN case ${TARGETARCH} in \
         "amd64") LEFTHOOK_ARCH="x86_64"  ;; \
         "arm64") LEFTHOOK_ARCH="arm64" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/evilmartians/lefthook/releases/download/v${LEFTHOOK_VERSION}/lefthook_${LEFTHOOK_VERSION}_Linux_${LEFTHOOK_ARCH}.gz" -o /usr/local/bin/lefthook.gz && \
    gunzip /usr/local/bin/lefthook.gz && \
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
