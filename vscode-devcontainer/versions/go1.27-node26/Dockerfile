# syntax=docker/dockerfile:1

# ==============================================================================
# Global Arguments
# ==============================================================================
ARG GO_VERSION=1.27.1
ARG DEBIAN_VERSION=trixie-20260824

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

ENV TBLS_VERSION=v1.95.0 \
    AIR_VERSION=v1.67.4 \
    DELVE_VERSION=v1.27.1 \
    MOCKGEN_VERSION=v0.6.0 \
    TEMPL_VERSION=v0.3.1020 \
    BUF_VERSION=v1.72.0 \
    PROTOC_GEN_VALIDATE_VERSION=v1.3.3 \
    PROTOC_GEN_GO_VERSION=v1.36.12 \
    PROTOC_GEN_GO_GRPC_VERSION=v1.6.2 \
    PROTOC_GEN_CONNECT_GO_VERSION=v1.20.0 \
    GRPC_GATEWAY_VERSION=v2.30.0 \
    OAPI_VERSION=v2.8.0 \
    GOLANGCI_LINT_VERSION=v2.13.2 \
    CONFTEST_VERSION=v0.69.0 \
    D2_VERSION=v0.8.2

RUN --mount=type=cache,target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,target=/root/.cache/go-build,sharing=locked \
    go install -ldflags="-s -w" golang.org/x/tools/gopls@latest && \
    go install -ldflags="-s -w" golang.org/x/tools/cmd/goimports@latest && \
    go install -ldflags="-s -w" github.com/k1LoW/tbls@${TBLS_VERSION} && \
    go install -ldflags="-s -w" github.com/air-verse/air@${AIR_VERSION} && \
    go install -ldflags="-s -w" github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION} && \
    go install -ldflags="-s -w" go.uber.org/mock/mockgen@${MOCKGEN_VERSION} && \
    go install -ldflags="-s -w" github.com/a-h/templ/cmd/templ@${TEMPL_VERSION} && \
    go install -ldflags="-s -w" github.com/bufbuild/buf/cmd/buf@${BUF_VERSION} && \
    go install -ldflags="-s -w" github.com/envoyproxy/protoc-gen-validate/cmd/protoc-gen-validate-go@${PROTOC_GEN_VALIDATE_VERSION} && \
    go install -ldflags="-s -w" google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION} && \
    go install -ldflags="-s -w" google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION} && \
    go install -ldflags="-s -w" connectrpc.com/connect/cmd/protoc-gen-connect-go@${PROTOC_GEN_CONNECT_GO_VERSION} && \
    go install -ldflags="-s -w" github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@${GRPC_GATEWAY_VERSION} && \
    go install -ldflags="-s -w" github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@${GRPC_GATEWAY_VERSION} && \
    go install -ldflags="-s -w" github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@${OAPI_VERSION} && \
    go install -ldflags="-s -w" github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${GOLANGCI_LINT_VERSION} && \
    go install -ldflags="-s -w" github.com/open-policy-agent/conftest@${CONFTEST_VERSION} && \
    go install -ldflags="-s -w" github.com/d2lang/d2@${D2_VERSION} && \
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

RUN echo "path-exclude=/usr/share/doc/*" > /etc/dpkg/dpkg.cfg.d/01-nodoc \
    && echo "path-exclude=/usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/01-nodoc \
    && echo "path-exclude=/usr/share/groff/*" >> /etc/dpkg/dpkg.cfg.d/01-nodoc \
    && echo "path-exclude=/usr/share/info/*" >> /etc/dpkg/dpkg.cfg.d/01-nodoc \
    && echo "path-exclude=/usr/share/lintian/*" >> /etc/dpkg/dpkg.cfg.d/01-nodoc \
    && echo "path-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/01-nodoc
    # copyright: ライセンス表記のため除外対象から除く

RUN --mount=type=cache,target=/var/cache/apt/archives,id=apt-archives-${TARGETARCH},sharing=locked \
    rm -f /var/cache/apt/archives/lock && \
    apt-get update && apt-get install -y --no-install-recommends \
    git \
    bash \
    make \
    curl \
    wget \
    unzip \
    ca-certificates \
    openssh-client \
    openjdk-25-jre-headless \
    jq \
    less \
    python3 \
    python3-pip \
    protobuf-compiler \
    gnupg \
    lsb-release \
    shellcheck \
    postgresql-client \
    xz-utils \
    locales \
    lsof \
    iproute2 \
    librsvg2-bin \
    fonts-noto-cjk \
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
    && find /opt/flyway/drivers -mindepth 1 -maxdepth 1 ! -name 'postgresql-*.jar' -exec rm -rf {} + \
    && ln -s /opt/flyway/flyway /usr/local/bin/flyway \
    && rm flyway.tar.gz

# ------------------------------------------------------------------------------
# OpenAPI Generator
# ------------------------------------------------------------------------------
ENV OPENAPI_GENERATOR_VERSION=7.25.0 \
    OPENAPI_GENERATOR_SHA1=56a9bb79e3bb565f477eddca2c6daa288a9c6f35

RUN mkdir -p /opt/openapi-generator \
    && curl -fsSL "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/${OPENAPI_GENERATOR_VERSION}/openapi-generator-cli-${OPENAPI_GENERATOR_VERSION}.jar" -o /opt/openapi-generator/openapi-generator-cli.jar \
    && echo "${OPENAPI_GENERATOR_SHA1}  /opt/openapi-generator/openapi-generator-cli.jar" | sha1sum -c - \
    && printf '#!/bin/sh\nexec java -jar /opt/openapi-generator/openapi-generator-cli.jar "$@"\n' > /usr/local/bin/openapi-generator-cli \
    && chmod +x /usr/local/bin/openapi-generator-cli

# ------------------------------------------------------------------------------
# gcloud
# ------------------------------------------------------------------------------
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
RUN --mount=type=cache,target=/var/cache/apt/archives,id=apt-archives-${TARGETARCH},sharing=locked \
    rm -f /var/cache/apt/archives/lock && \
    apt-get update && apt-get install -y --no-install-recommends google-cloud-cli \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/bin/anthoscli /usr/lib/google-cloud-sdk/bin/anthoscli \
              /usr/lib/google-cloud-sdk/platform/anthoscli_licenses \
              /usr/lib/google-cloud-sdk/.install/anthoscli* \
    && rm -rf /usr/bin/gsutil /usr/lib/google-cloud-sdk/bin/gsutil \
              /usr/lib/google-cloud-sdk/platform/gsutil \
              /usr/lib/google-cloud-sdk/.install/gsutil* \
              /usr/lib/google-cloud-sdk/lib/third_party/botocore \
              /usr/lib/google-cloud-sdk/lib/third_party/boto3

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
    CHECKOV_VERSION=3.3.16

RUN uv tool install "checkov==${CHECKOV_VERSION}"

# ------------------------------------------------------------------------------
# Node.js Tools (pnpm, rulesync など)
# ------------------------------------------------------------------------------
ENV NPM_VERSION=12.0.2 \
    PNPM_VERSION=12.2.1 \
    RULESYNC_VERSION=16.20.0

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y --no-install-recommends nodejs

RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm install -g "npm@${NPM_VERSION}" --force && \
    npm install -g --allow-scripts=pnpm "pnpm@${PNPM_VERSION}" && \
    npm install -g "rulesync@${RULESYNC_VERSION}" && \
    npm cache clean --force

# ------------------------------------------------------------------------------
# Playwright CLI + chromium
# ------------------------------------------------------------------------------
# `npx playwright install-deps chromium` が要求するパッケージ
RUN --mount=type=cache,target=/var/cache/apt/archives,id=apt-archives-${TARGETARCH},sharing=locked \
    rm -f /var/cache/apt/archives/lock && \
    apt-get update && apt-get install -y --no-install-recommends \
    libasound2t64 libatk-bridge2.0-0t64 libatk1.0-0t64 libatspi2.0-0t64 \
    libcairo2 libcups2t64 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0t64 \
    libnspr4 libnss3 libpango-1.0-0 \
    libx11-6 libxcb1 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
    libxkbcommon0 libxrandr2 \
    libfontconfig1 libfreetype6 \
    fonts-noto-color-emoji fonts-liberation \
    fonts-tlwg-loma-otf fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# PLAYWRIGHT_BROWSERS_VERSION は @playwright/test (pnpm-lock.yaml) と合わせること。
# Playwright MCP（.mcp.json）は別バージョンなので別途 npx が自動解決する。
ENV PLAYWRIGHT_BROWSERS_VERSION=1.62.1 \
    PLAYWRIGHT_CLI_VERSION=0.1.19

# /usr/local/bin/chrome: chromium (full build) 実体への symlink。
# mermaid-cli/marp-cli から同一バイナリを再利用させ、二重ダウンロードを防ぐ
# （後段 Diagram Tools セクションの PUPPETEER_EXECUTABLE_PATH / CHROME_PATH参照）。
# --no-shell: chromium-headless-shell（arm64 実測 345MB）を入れない。
# mermaid-cli/marp-cli は chromium 本体しか使わず、Playwright 自身の headless
# 実行も shell 未インストール時は chromium 本体にフォールバックする
# （公式ドキュメントに明記されたサポート済みオプション）。
RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm install -g "@playwright/cli@${PLAYWRIGHT_CLI_VERSION}" \
                   "playwright@${PLAYWRIGHT_BROWSERS_VERSION}" && \
    npx --yes "playwright@${PLAYWRIGHT_BROWSERS_VERSION}" install chromium --no-shell && \
    ln -s "$(find /root/.cache/ms-playwright -name chrome -type f -executable | head -n1)" /usr/local/bin/chrome && \
    npm cache clean --force

# ------------------------------------------------------------------------------
# Docker CLI（daemon なし）
# ------------------------------------------------------------------------------
RUN dpkg --get-selections docker.io docker-doc docker-compose docker-compose-v2 \
    podman-docker containerd runc 2>/dev/null | cut -f1 | xargs -r apt-get remove -y \
    && apt autoremove -y
RUN --mount=type=cache,target=/var/cache/apt/archives,id=apt-archives-${TARGETARCH},sharing=locked \
    rm -f /var/cache/apt/archives/lock && \
    install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && printf "Types: deb\n\
URIs: https://download.docker.com/linux/debian\n\
Suites: %s\n\
Components: stable\n\
Signed-By: /etc/apt/keyrings/docker.asc\n" "$(. /etc/os-release && echo "$VERSION_CODENAME")" > /etc/apt/sources.list.d/docker.sources \
    && apt-get update \
    && apt install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin \
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
    && rm -rf aws \
    && find /usr/local/aws-cli -type d -name examples -exec rm -rf {} +

# ------------------------------------------------------------------------------
# Antigravity
# ------------------------------------------------------------------------------
# ANTIGRAVITY_AMD64_URL / ANTIGRAVITY_ARM64_URL: The fixed version URL for GCS.
# ANTIGRAVITY_AMD64_SHA512 / ANTIGRAVITY_ARM64_SHA512: SHA512 checksum.
# When updating the version: Check the latest manifest at https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/linux_{amd64,arm64}.json and update.
ENV GOOGLE_CLOUD_LOCATION=global \
    GOOGLE_GENAI_USE_VERTEXAI=true \
    ADK_SUPPRESS_GEMINI_LITELLM_WARNINGS=true \
    ANTIGRAVITY_VERSION=1.1.24 \
    ANTIGRAVITY_AMD64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.24-6130423206641664/linux-x64/cli_linux_x64.tar.gz \
    ANTIGRAVITY_AMD64_SHA512=ed4df91ea7ced986aa14507a0ab8225d92985190f7d551010eba0c46c569587e602cb36af81c9cde7af0d6b380e8dd3a82131361806cd96012d44a3e47fb369a \
    ANTIGRAVITY_ARM64_URL=https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.24-6130423206641664/linux-arm/cli_linux_arm64.tar.gz \
    ANTIGRAVITY_ARM64_SHA512=316ca00d50389a08b162c66066b4e2db201e4ffb85acea05029e3c4532c69d5b8f7c741cf027325889f898ea8f747af8cd15c802e15fcf5d73b7137b6e2420a1

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
ENV ARCHGATE_VERSION=0.55.0 \
    ARCHGATE_GIT_SHA=47a2ac35a049fc4a27a28f4199ad67d3a17f8390 \
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
    rm -rf /tmp/archgate-src /tmp/bun /root/.bun; \
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
ENV LEFTHOOK_VERSION=2.1.12 \
    LEFTHOOK_SHA256_X86_64=dad908593c859d139b886c14913a44401d95288aa7642d9bdf6f3bd36bd788ff \
    LEFTHOOK_SHA256_ARM64=0e29b0232d91e57509cb97062996bb98ff7113f2374b260ade3331a178d3263a

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
# Diagram Tools
# ------------------------------------------------------------------------------
# mermaid-cli (puppeteer 経由) は PUPPETEER_EXECUTABLE_PATH を、
# marp-cli (puppeteer-core + 独自 chrome-launcher) は CHROME_PATH を参照。
ENV MERMAID_CLI_VERSION=11.16.0 \
    MARP_CLI_VERSION=4.5.0 \
    PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/local/bin/chrome \
    CHROME_PATH=/usr/local/bin/chrome

RUN --mount=type=cache,target=/root/.npm,sharing=locked \
    npm install -g "@mermaid-js/mermaid-cli@${MERMAID_CLI_VERSION}" \
                   "@marp-team/marp-cli@${MARP_CLI_VERSION}" && \
    npm cache clean --force

# LibreOffice (soffice) + poppler-utils (pdftoppm)
RUN --mount=type=cache,target=/var/cache/apt/archives,id=apt-archives-${TARGETARCH},sharing=locked \
    rm -f /var/cache/apt/archives/lock && \
    apt-get update && apt-get install -y --no-install-recommends \
    libreoffice-impress-nogui \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

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
