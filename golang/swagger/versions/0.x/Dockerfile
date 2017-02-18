# go-swagger v0.8.x
#
# docker run --rm -v $(pwd):/go/src supinf/go-swagger validate ./swagger.yml
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/go-swagger generate server -A sample -f ./swagger.yml
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/go-swagger generate client -A sample -f ./swagger.yml

FROM alpine:3.5

# Commit at Feb 16, 2017, 06:57 AM
ENV SWAGGER_VERSION=54d23b6fa46c29ccb7e834154e2f0c0fba33f0d1 \
    GOPATH=/go

RUN apk --no-cache add --virtual build-dependencies bash gcc musl-dev openssl go git \

    # Install go 1.8
    && GOLANG_VERSION=1.8 \
    && GOLANG_SRC_URL=https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz \
    && GOLANG_SRC_SHA256=406865f587b44be7092f206d73fc1de252600b79b3cacc587b74b5ef5c623596 \
    && export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
    && wget -q "$GOLANG_SRC_URL" -O golang.tar.gz \
    && echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && wget -q https://raw.githubusercontent.com/docker-library/golang/master/1.8/alpine/no-pic.patch \
    && cd /usr/local/go/src \
    && patch -p2 -i /no-pic.patch \
    && ./make.bash \
    && export PATH=/go/bin:/usr/local/go/bin:$PATH \
    && mkdir -p /go/src \
    && chmod -R 777 /go \

    # Install go-swagger
    && go get -u github.com/go-swagger/go-swagger/cmd/swagger \
    && cd /go/src/github.com/go-swagger/go-swagger \
    && git checkout ${SWAGGER_VERSION} \
    && go install github.com/go-swagger/go-swagger/cmd/swagger \
    && mv /go/bin/swagger /usr/bin/ \

    # Clean up
    && apk del --purge -r build-dependencies \
    && rm -rf /usr/local/go /usr/lib/go /go /var/cache/* /var/lib/apk*

WORKDIR /go/src

ENTRYPOINT ["swagger"]
CMD ["-h"]
