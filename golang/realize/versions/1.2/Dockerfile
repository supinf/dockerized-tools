# realize v1.2
#
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/go-realize run

FROM supinf/go:1.8

ENV REALIZE_VERSION=1.2.2

RUN apk --no-cache add g++
RUN apk --no-cache add --virtual build-dependencies git \

    # Compile realize
    && go get github.com/tockins/realize \
    && cd /go/src/github.com/tockins/realize \
    && git checkout v${REALIZE_VERSION} \
    && go install \

    # Clean up
    && apk del --purge -r build-dependencies \
    && rm -rf /go/src/* /go/pkg

ENTRYPOINT ["realize"]
CMD ["-h"]
