# Godep v79 (go v1.8)
#
# docker run --rm -v $GOPATH:/go -w /go/src/github.com/your-account/project pottava/godep save ./...
# docker run --rm -v $GOPATH:/go -w /go/src/github.com/your-account/project pottava/godep update foo/...
# docker run --rm -v $GOPATH:/go -w /go/src/github.com/your-account/project pottava/godep restore

FROM pottava/golang:1.8-builder

ENV GODEP_VERSION=79

RUN apk --no-cache add git

RUN REPOSITORY=$GOPATH/src/github.com/tools/godep \
    && git clone --depth=1 -b v${GODEP_VERSION} https://github.com/tools/godep.git $REPOSITORY \
    && cd $REPOSITORY \
    && go install \
    && mv /go/bin/godep /usr/bin \
    && rm -rf /go /var/cache/*

ENTRYPOINT ["godep"]
