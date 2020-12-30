# ShellCheck http://www.shellcheck.net
# docker run --rm -v $(pwd):/work ghcr.io/supinf/shellcheck:0.7
# docker run --rm -v $(pwd):/work -e IGNORE_PATH=/vendor/ ghcr.io/supinf/shellcheck:0.7

FROM alpine:3.12

ENV SHELLCHECK_VERSION=v0.7.1

RUN apk --no-cache add bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apk --no-cache --virtual=build-deps add curl \
    && tar=shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && curl -sSL https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/${tar} -o shellcheck.tar.gz \
    && mkdir -p /usr/src/shellcheck \
    && tar xvf shellcheck.tar.gz \
    && mv shellcheck-*/shellcheck /usr/bin/ \
    && rm -rf shellcheck* \
    && apk del --purge -r build-deps

WORKDIR /work

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
