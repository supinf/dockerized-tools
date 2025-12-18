# syntax=docker/dockerfile:1

# ==============================================================================
# Global Arguments
# ==============================================================================
ARG GO_VERSION=1.25.5
ARG DEBIAN_VERSION=trixie-20251208
# ARG GO_VERSION=1.25.5-debian13
# ARG DEBIAN_VERSION=trixie-debian13-fips

# ==============================================================================
# Stage 1: Go Tool Builder
# ==============================================================================
FROM golang:${GO_VERSION}-bookworm AS go-builder
# FROM dhi.io/golang:${GO_VERSION}-dev AS go-builder

ARG TARGETARCH

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=${TARGETARCH}

ENV AIR_VERSION=v1.63.4 \
    DELVE_VERSION=v1.26.0 \
    MOCKGEN_VERSION=v0.6.0 \
    BUF_VERSION=v1.61.0 \
    PROTOC_GEN_GO_VERSION=v1.36.10 \
    PROTOC_GEN_GO_GRPC_VERSION=v1.6.0 \
    PROTOC_GEN_CONNECT_GO_VERSION=v1.19.1 \
    GRPC_GATEWAY_VERSION=v2.27.4 \
    OAPI_VERSION=v2.5.1 \
    GOLANGCI_LINT_VERSION=v2.7.2

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go install github.com/air-verse/air@${AIR_VERSION} && \
    go install github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} && \
    go install go.uber.org/mock/mockgen@${MOCKGEN_VERSION} && \
    go install github.com/bufbuild/buf/cmd/buf@${BUF_VERSION} && \
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
    curl \
    wget \
    unzip \
    ca-certificates \
    openjdk-25-jdk-headless \
    maven \
    jq \
    python3 \
    python3-pip \
    protobuf-compiler \
    libprotobuf-dev \
    gnupg lsb-release \
    locales \
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
# OpenAPI Generator CLI
# ------------------------------------------------------------------------------
ENV OPENAPI_GENERATOR_VERSION=7.17.0

RUN curl -fsSL https://raw.githubusercontent.com/OpenAPITools/openapi-generator/"v${OPENAPI_GENERATOR_VERSION}"/bin/utils/openapi-generator-cli.sh -o /usr/local/bin/openapi-generator-cli \
    && chmod +x /usr/local/bin/openapi-generator-cli

# ------------------------------------------------------------------------------
# Python Tools (uv など)
# ------------------------------------------------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH=/root/.local/bin:$PATH

# ------------------------------------------------------------------------------
# Node.js Tools (pnpm, rulesync など)
# ------------------------------------------------------------------------------
ENV NPM_VERSION=11.7.0 \
    PNPM_VERSION=10.26.2 \
    RULESYNC_VERSION=4.3.1 \
    CONTEXT7_VERSION=2.0.0

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs

RUN --mount=type=cache,target=/root/.npm \
    npm install -g "npm@${NPM_VERSION}" --force && \
    npm install -g "pnpm@${PNPM_VERSION}" && \
    npm install -g "rulesync@${RULESYNC_VERSION}" && \
    npm install -g "@upstash/context7-mcp@${CONTEXT7_VERSION}" && \
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
    ANTHROPIC_MODEL=claude-sonnet-4-5-20250929 \
    ANTHROPIC_SMALL_FAST_MODEL=claude-haiku-4-5-20251001

# ------------------------------------------------------------------------------
# Gemini
# ------------------------------------------------------------------------------
ENV GOOGLE_CLOUD_LOCATION=global \
    GOOGLE_GENAI_USE_VERTEXAI=true \
    GEMINI_MODEL="gemini-3-flash-preview" \
    GEMINI_CLI_VERSION=0.22.5

RUN npm install -g "@google/gemini-cli@${GEMINI_CLI_VERSION}"

# ------------------------------------------------------------------------------
# Go
# ------------------------------------------------------------------------------
COPY --from=go-builder /usr/local/go /usr/local/go
ENV PATH=$PATH:/usr/local/go/bin:/go/bin
ENV GOPATH=/go

COPY --from=go-builder /go/bin /go/bin

ENV CGO_ENABLED=0 \
    GO111MODULE=on \
    GOEXPERIMENT=rangefunc

ENTRYPOINT [ "sleep", "infinity" ]
