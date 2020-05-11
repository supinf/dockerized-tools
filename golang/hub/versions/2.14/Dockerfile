# hub v2.14
# docker run --rm supinf/hub version
# docker run --rm -v "${HOME}"/.gitconfig:/root/.gitconfig -v "${HOME}"/.ssh:/root/.ssh supinf/hub pull-request

FROM golang:alpine3.11 as builder

ENV HUB_VERSION=v2.14.2
ENV GIT_VERSION=2.24.3-r0

RUN apk update
RUN apk add git=${GIT_VERSION} make gcc g++ bash util-linux groff
RUN git clone \
    --config transfer.fsckobjects=false \
    --config receive.fsckobjects=false \
    --config fetch.fsckobjects=false \
    --depth=1 -b ${HUB_VERSION} \
    https://github.com/github/hub.git
RUN cd hub && bash -c 'make install prefix=/usr/local'

FROM alpine:3.11
COPY --from=builder /usr/local/bin/hub /usr/local/bin/hub
COPY --from=builder /usr/bin/git /usr/bin/git
COPY --from=builder /usr/lib/libpcre2-8.so.0 /usr/lib/libpcre2-8.so.0

WORKDIR /work

ENTRYPOINT ["hub"]
