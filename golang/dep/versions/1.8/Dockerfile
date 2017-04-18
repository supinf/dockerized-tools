# golang/dep (go v1.8)
#
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/go-dep ensure

FROM alpine:3.5

# Commit at Apr 17, 2017, 19:21 PM UTC
ENV GODEP_VERSION=477398819a549a19de3927435f70c43bb600e27c \
    GOPATH=/go

WORKDIR /go/src

RUN apk --no-cache add git
RUN apk --no-cache add --virtual build-dependencies bash gcc musl-dev openssl go \

    # Install go 1.8
    && GOLANG_VERSION=1.8.1 \
    && GOLANG_SRC_URL=https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz \
    && GOLANG_SRC_SHA256=33daf4c03f86120fdfdc66bddf6bfff4661c7ca11c5da473e537f4d69b470e57 \
    && export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
    && wget -q "$GOLANG_SRC_URL" -O golang.tar.gz \
    && echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && wget -q https://raw.githubusercontent.com/docker-library/golang/master/1.8/alpine/no-pic.patch \
    && cd /usr/local/go/src \
    && patch -p2 -i /go/src/no-pic.patch \
    && ./make.bash \
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
