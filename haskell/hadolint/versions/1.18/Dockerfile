# Haskell Dockerfile Linter v1.18
# @see https://github.com/hadolint/hadolint
#
# docker run --rm -v $(pwd):/work supinf/hadolint:1.18
# docker run --rm -v $(pwd):/work -e DOCKERFILE_NAME=Dockerfile.prod supinf/hadolint:1.18

FROM alpine:3.12 AS build

ENV HADOLINT_VERSION='v1.18.0'

RUN apk --no-cache --virtual=build-deps add curl=7.69.1-r0 bash=5.0.17-r0
RUN curl --location --silent -o /usr/bin/hadolint \
    "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64"
RUN chmod +x /usr/bin/hadolint

FROM alpine:3.12

ENV HADOLINT_VERSION='v1.18.0' \
    DOCKERFILE_NAME='Dockerfile'

COPY entrypoint.sh /
COPY --from=build /usr/bin/hadolint /usr/bin/hadolint
WORKDIR /work
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
