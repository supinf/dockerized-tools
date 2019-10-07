# golangci-lint
# docker run --rm -v $(pwd):/go/src/github.com/your-name/project -w /go/src/github.com/your-name/project supinf/golangci-lint:1.19 run --config .golangci.yml

FROM alpine:3.10 AS build
RUN apk --no-cache add wget
ENV GOLANGCI_LINT_VERSION=1.19.1 \
    GOLANGCI_LINT_REPO=github.com/golangci/golangci-lint
ENV GOLANGCI_LINT_URL="https://${GOLANGCI_LINT_REPO}/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz" \
    GOLANGCI_LINT_SHA256="03ca6a77734720581b11a78e5fd4ce6d6bfd8f36768b214bb9890980b6db261f"
RUN wget -q "${GOLANGCI_LINT_URL}" -O golangci-lint.tar.gz
RUN echo "${GOLANGCI_LINT_SHA256}  golangci-lint.tar.gz" | sha256sum -c -
RUN tar -xzf golangci-lint.tar.gz
RUN mv "golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64/golangci-lint" /
RUN chmod +x /golangci-lint

FROM golang:1.13.1-alpine3.10
RUN apk --no-cache add gcc musl-dev
COPY --from=build /golangci-lint /usr/bin/
ENTRYPOINT ["golangci-lint"]
CMD ["--help"]
