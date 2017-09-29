# godep v79
#
# docker run --rm supinf/godep:79 --help
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/godep:79 restore

FROM supinf/go:1.9-builder

ENV GODEP_VERSION=v79

RUN apk --no-cache add git

RUN go get github.com/tools/godep \
    && cd /go/src/github.com/tools/godep \
    && git checkout ${GODEP_VERSION} \
    && go install github.com/tools/godep \
    && mv /go/bin/godep /usr/bin \
    && rm -rf /go/src /var/cache/* /var/lib/apk*

ENTRYPOINT ["godep"]
CMD ["help"]
