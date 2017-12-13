# ShellCheck http://www.shellcheck.net
# docker run --rm -it -v $(pwd):/work supinf/shellcheck

FROM alpine:3.6

ENV SHELLCHECK_VERSION=v0.4.7

ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh \
    && apk --no-cache --virtual=build-dependencies add curl \
    && tar=shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && curl -sSL https://shellcheck.storage.googleapis.com/${tar} -o shellcheck.tar.gz \
    && echo "64bf19a1292f0357c007b615150b6e58dba138bc7bf168c5a5e27016f8b4f802afd9950be8be46bf9e4833f98ae81c6e7b1761a3a76ddbba2a04929265433134  shellcheck.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/src/shellcheck \
    && tar xvf shellcheck.tar.gz \
    && mv shellcheck-*/shellcheck /usr/bin/ \
    && rm -rf shellcheck* \
    && apk del --purge -r build-dependencies

WORKDIR /work

ENTRYPOINT ["/entrypoint.sh"]
