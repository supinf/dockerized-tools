# Haskell Dockerfile Linter v1.19
# @see https://github.com/hadolint/hadolint
#
# docker run --rm -v $(pwd):/work ghcr.io/supinf/hadolint:1.19
# docker run --rm -v $(pwd):/work -e DOCKERFILE_NAME=Dockerfile.prod ghcr.io/supinf/hadolint:1.19

FROM alpine:3.12 AS build

ENV HADOLINT_VERSION='v1.19.0'

RUN apk --no-cache add curl
RUN curl --location --silent -o /usr/bin/hadolint \
    "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64"
RUN chmod +x /usr/bin/hadolint

FROM alpine:3.12
ENV HADOLINT_VERSION='v1.19.0' \
    DOCKERFILE_NAME='Dockerfile'
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh 
COPY --from=build /usr/bin/hadolint /usr/bin/hadolint
WORKDIR /work
ENTRYPOINT ["/entrypoint.sh"]
