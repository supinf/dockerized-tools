# syntax=docker/dockerfile:1

# ==============================================================================
# Global Arguments
# ==============================================================================
ARG DEBIAN_VERSION=trixie-20260421
# ARG DEBIAN_VERSION=trixie-debian13-fips

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
    jq \
    less \
    python3 \
    python3-pip \
    protobuf-compiler \
    libprotobuf-dev \
    gnupg lsb-release \
    postgresql-client \
    locales \
    lsof iproute2 \
    && localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# OpenAPI Generator
# ------------------------------------------------------------------------------
ENV OPENAPI_GENERATOR_VERSION=7.22.0

RUN curl -fsSL https://raw.githubusercontent.com/OpenAPITools/openapi-generator/"v${OPENAPI_GENERATOR_VERSION}"/bin/utils/openapi-generator-cli.sh -o /usr/local/bin/openapi-generator-cli \
    && chmod +x /usr/local/bin/openapi-generator-cli

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
ENV PATH=/root/.local/bin:$PATH

# ------------------------------------------------------------------------------
# Node.js Tools (pnpm, rulesync など)
# ------------------------------------------------------------------------------
ENV NPM_VERSION=11.13.0 \
    PNPM_VERSION=10.33.2 \
    RULESYNC_VERSION=8.15.0

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs

RUN --mount=type=cache,target=/root/.npm \
    npm install -g "npm@${NPM_VERSION}" --force && \
    npm install -g "pnpm@${PNPM_VERSION}" && \
    npm install -g "rulesync@${RULESYNC_VERSION}" && \
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
ENV CLAUDE_CODE_USE_BEDROCK=false \
    AWS_REGION=ap-northeast-1 \
    CLAUDE_CODE_USE_VERTEX=false \
    CLOUD_ML_REGION=global \
    ANTHROPIC_MODEL=claude-sonnet-4-6@default \
    ANTHROPIC_SMALL_FAST_MODEL=claude-haiku-4-5@20251001

# ------------------------------------------------------------------------------
# Cline
# ------------------------------------------------------------------------------
ENV CLINE_AWS_REGION=ap-northeast-1 \
    CLINE_BEDROCK_MODEL_ID=global.anthropic.claude-sonnet-4-6 \
    CLINE_VERTEX_REGION=global \
    CLINE_VERTEX_MODEL_ID=claude-sonnet-4-6@default \
    CLINE_OPENAI_BASE_URL=https://api.openai.com/v1 \
    CLINE_OPENAI_MODEL=gpt-5.3-codex

# ------------------------------------------------------------------------------
# Codex
# ------------------------------------------------------------------------------
ENV CODEX_CLI_VERSION=0.128.0 \
    CODEX_HOME=/root/.codex \
    OPENAI_BASE_URL=https://api.openai.com/v1 \
    CODEX_MODEL=gpt-5.3-codex

RUN npm install -g "@openai/codex@${CODEX_CLI_VERSION}"

# ------------------------------------------------------------------------------
# Gemini
# ------------------------------------------------------------------------------
ENV GOOGLE_CLOUD_LOCATION=global \
    GOOGLE_GENAI_USE_VERTEXAI=true \
    GEMINI_CLI_VERSION=0.40.1 \
    ADK_SUPPRESS_GEMINI_LITELLM_WARNINGS=true

RUN npm install -g "@google/gemini-cli@${GEMINI_CLI_VERSION}"

# ------------------------------------------------------------------------------
# Archgate
# ------------------------------------------------------------------------------
# ARCHGATE_GIT_SHA: the git commit SHA corresponding to ARCHGATE_VERSION.
# Update both together when bumping the version.
# To find the SHA: npm view archgate@<version> gitHead
ENV ARCHGATE_VERSION=0.31.2 \
    ARCHGATE_GIT_SHA=b2ec6511aab6d49da4a84001e6ee71195c42eb86

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
    npm install -g "archgate@${ARCHGATE_VERSION}"; \
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

ENTRYPOINT [ "sleep", "infinity" ]
