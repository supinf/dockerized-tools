# go-swagger v0.30.3
# docker run --rm -v $(pwd):/go/src ghcr.io/supinf/go-swagger:0.30 validate ./swagger.yml
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project ghcr.io/supinf/go-swagger:0.30 generate server -A sample -f ./swagger.yml
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project ghcr.io/supinf/go-swagger:0.30 generate client -A sample -f ./swagger.yml

FROM golang:1.19.1-alpine3.16 AS build
RUN apk --no-cache add bash g++ openssl git
RUN go get -u github.com/mitchellh/gox

ENV SWAGGER_VERSION=v0.30.3

ENV REPO="github.com/go-swagger/go-swagger/cmd/swagger"
RUN go get -u "${REPO}"
WORKDIR /go/src/github.com/go-swagger/go-swagger
RUN git checkout "${SWAGGER_VERSION}"
RUN gox --osarch "linux/amd64" -output /swagger \
      -ldflags "-s -w -X ${REPO}/commands.Version=${SWAGGER_VERSION} -X ${REPO}/commands.Commit=$(git rev-parse --short HEAD)" \
      "${REPO}"

FROM alpine:3.16
COPY --from=build /swagger /usr/bin/swagger
ENV GOPATH=/go
WORKDIR /go/src
ENTRYPOINT ["swagger"]
CMD ["-h"]
