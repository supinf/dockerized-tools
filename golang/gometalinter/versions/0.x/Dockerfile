# gometalinter
#
# docker run --rm -v $(pwd):/go/src/github.com/your-name/project -w /go/src/github.com/your-name/project supinf/gometalinter
# docker run --rm -v $(pwd):/go/src/github.com/your-name/project -w /go/src/github.com/your-name/project supinf/gometalinter

FROM alpine:3.6

# Commit at Nov 22, 2017, 19:44 PM
ENV METALINTER_VERSION=08effb25e09dc5b2280e96921ec60842e49a4106 \
    PATH=/go/bin:/usr/local/go/bin:$PATH \
    PAGER=less \
    GOPATH=/go

RUN apk --no-cache add less
RUN apk --no-cache add --virtual build-dependencies bash gcc musl-dev openssl go git \

    # Install go 1.9
    && GOLANG_VERSION=1.9.2 \
    && GOLANG_SRC_URL=https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz \
    && GOLANG_SRC_SHA256=665f184bf8ac89986cfd5a4460736976f60b57df6b320ad71ad4cef53bb143dc \
    && export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
    && wget -q "$GOLANG_SRC_URL" -O golang.tar.gz \
    && echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && wget -q https://raw.githubusercontent.com/docker-library/golang/master/1.9/alpine3.6/no-pic.patch \
    && cd /usr/local/go/src \
    && patch -p2 -i /no-pic.patch \
    && ./make.bash \
    && mkdir -p /go/src \
    && chmod -R 777 /go \

    # Install gometalinter
    && go get -u github.com/alecthomas/gometalinter \
    && cd /go/src/github.com/alecthomas/gometalinter \
    && git checkout ${METALINTER_VERSION} \
    && go install github.com/alecthomas/gometalinter \
    && gometalinter --install \

    # Clean up
    && apk del --purge -r build-dependencies \
    && find /usr/local/go -depth -type d -name testdata -exec rm -rf {} \; \
    && find / -depth -type f -name "*_test.go" -exec rm -f {} \; \
    && find / -depth -type f -name README.md -exec rm -f {} \; \
    && rm -rf /var/cache/* /var/lib/apk*

WORKDIR /go/src

ENTRYPOINT ["gometalinter"]
CMD ["--help"]
