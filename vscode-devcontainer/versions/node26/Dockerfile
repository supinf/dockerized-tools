# syntax=docker/dockerfile:1

# ==============================================================================
# Global Arguments
# ==============================================================================
ARG DEBIAN_VERSION=trixie-20260905

# ==============================================================================
# Development Environment
# ==============================================================================
FROM debian:${DEBIAN_VERSION}

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
    && localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

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
              /usr/lib/google-cloud-sdk/.install/gsutil*

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
    PNPM_VERSION=12.3.4 \
    RULESYNC_VERSION=16.24.0

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
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-tlwg-loma-otf fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# PLAYWRIGHT_BROWSERS_VERSION は @playwright/test (pnpm-lock.yaml) と合わせること。
# Playwright MCP（.mcp.json）は別バージョンなので別途 npx が自動解決する。
ENV PLAYWRIGHT_BROWSERS_VERSION=1.63.0 \
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

ENTRYPOINT [ "sleep", "infinity" ]
