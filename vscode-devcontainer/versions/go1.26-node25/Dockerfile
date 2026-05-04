# syntax=docker/dockerfile:1

# ==============================================================================
# Global Arguments
# ==============================================================================
ARG GO_VERSION=1.26.2
ARG DEBIAN_VERSION=trixie-20260421
# ARG GO_VERSION=1.26.1-debian13
# ARG DEBIAN_VERSION=trixie-debian13-fips

# ==============================================================================
# Stage 0: Go SDK (Target Architecture)
# ==============================================================================
FROM golang:${GO_VERSION}-bookworm AS go-sdk

# ==============================================================================
# Stage 1: Go Tool Builder (Cross-Compilation)
# ==============================================================================
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-bookworm AS tool-builder

ARG TARGETARCH

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=${TARGETARCH}

ENV TBLS_VERSION=v1.94.5 \
    AIR_VERSION=v1.65.1 \
    DELVE_VERSION=v1.26.3 \
    MOCKGEN_VERSION=v0.6.0 \
    TEMPL_VERSION=v0.3.1001 \
    BUF_VERSION=v1.69.0 \
    PROTOC_GEN_VALIDATE_VERSION=v1.3.3 \
    PROTOC_GEN_GO_VERSION=v1.36.11 \
    PROTOC_GEN_GO_GRPC_VERSION=v1.6.1 \
    PROTOC_GEN_CONNECT_GO_VERSION=v1.19.2 \
    GRPC_GATEWAY_VERSION=v2.29.0 \
    OAPI_VERSION=v2.7.0 \
    GOLANGCI_LINT_VERSION=v2.12.1

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go install golang.org/x/tools/gopls@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/k1LoW/tbls@${TBLS_VERSION} && \
    go install github.com/air-verse/air@${AIR_VERSION} && \
    go install github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} && \
    go install go.uber.org/mock/mockgen@${MOCKGEN_VERSION} && \
    go install github.com/a-h/templ/cmd/templ@${TEMPL_VERSION} && \
    go install github.com/bufbuild/buf/cmd/buf@${BUF_VERSION} && \
    go install github.com/envoyproxy/protoc-gen-validate/cmd/protoc-gen-validate-go@${PROTOC_GEN_VALIDATE_VERSION} && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION} && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION} && \
    go install connectrpc.com/connect/cmd/protoc-gen-connect-go@${PROTOC_GEN_CONNECT_GO_VERSION} && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@${GRPC_GATEWAY_VERSION} && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@${GRPC_GATEWAY_VERSION} && \
    go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@${OAPI_VERSION} && \
    go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${GOLANGCI_LINT_VERSION} && \
    if [ -d "/go/bin/linux_${TARGETARCH}" ]; then \
        mv /go/bin/linux_${TARGETARCH}/* /go/bin/; \
        rmdir /go/bin/linux_${TARGETARCH}; \
    fi

# ==============================================================================
# Stage 2: Development Environment
# ==============================================================================
FROM debian:${DEBIAN_VERSION}
# FROM dhi.io/debian-base:${DEBIAN_VERSION}

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
    openjdk-25-jdk-headless \
    maven \
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
# Flyway
# ------------------------------------------------------------------------------
ENV FLYWAY_VERSION=9.9.0 \
    JAVA_ARGS="--enable-native-access=ALL-UNNAMED"

RUN curl -L -o flyway.tar.gz https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}-linux-x64.tar.gz \
    && tar -xzf flyway.tar.gz \
    && mv flyway-${FLYWAY_VERSION} /opt/flyway \
    && rm -rf /opt/flyway/jre \
    && ln -s /opt/flyway/flyway /usr/local/bin/flyway \
    && rm flyway.tar.gz

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
# Docker
# ------------------------------------------------------------------------------
RUN for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done \
    && apt autoremove -y
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && printf "Types: deb\n\
URIs: https://download.docker.com/linux/debian\n\
Suites: %s\n\
Components: stable\n\
Signed-By: /etc/apt/keyrings/docker.asc\n" "$(. /etc/os-release && echo "$VERSION_CODENAME")" > /etc/apt/sources.list.d/docker.sources \
    && apt-get update \
    && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

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

# ------------------------------------------------------------------------------
# Go
# ------------------------------------------------------------------------------
COPY --from=go-sdk /usr/local/go /usr/local/go
ENV PATH=$PATH:/usr/local/go/bin:/go/bin
ENV GOPATH=/go

COPY --from=tool-builder /go/bin /go/bin

ENV CGO_ENABLED=0 \
    GO111MODULE=on

ENTRYPOINT [ "sleep", "infinity" ]
