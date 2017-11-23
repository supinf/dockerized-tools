# golang/dep v0.3
#
# docker run --rm supinf/go-dep:0.3 --help
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/go-dep:0.3 ensure

FROM alpine:3.6

ENV GODEP_VERSION=v0.3.2 \
    GOPATH=/go \
    PATH=/go/bin:/usr/local/go/bin:$PATH

WORKDIR /go/src

RUN apk --no-cache add git
RUN apk --no-cache add --virtual build-dependencies bash gcc musl-dev openssl go \

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
    && patch -p2 -i /go/src/no-pic.patch \
    && ./make.bash \
    && mkdir -p /go/src \
    && chmod -R 777 /go \

    # Compile golang/dep
    && go get -u github.com/golang/dep/... \
    && cd /go/src/github.com/golang/dep \
    && git checkout ${GODEP_VERSION} \
    && go install github.com/golang/dep/... \
    && mv /go/bin/dep /usr/bin \

    # Clean up
    && apk del --purge -r build-dependencies \
    && rm -rf /usr/local/go /usr/lib/go /go /var/cache/* /var/lib/apk*

ENTRYPOINT ["dep"]
CMD ["-h"]
