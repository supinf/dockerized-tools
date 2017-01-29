# gox (go v1.8)
#
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/gox --osarch "linux/amd64" -output "dist/{{.OS}}_{{.Arch}}"

FROM supinf/go:1.8

RUN apk --no-cache add g++
RUN apk --no-cache add --virtual build-dependencies git \

    # Install gox
    && go get -u github.com/mitchellh/gox \

    # Clean up
    && apk del --purge -r build-dependencies \
    && rm -rf /go/src/* /go/pkg

ENTRYPOINT ["gox"]
CMD ["-h"]
