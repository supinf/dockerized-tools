# go-swagger v0.25.0
# docker run --rm -v $(pwd):/go/src ghcr.io/supinf/go-swagger:0.25 validate ./swagger.yml
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project ghcr.io/supinf/go-swagger:0.25 generate server -A sample -f ./swagger.yml
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project ghcr.io/supinf/go-swagger:0.25 generate client -A sample -f ./swagger.yml

FROM golang:1.15.6-alpine3.12 AS build
RUN apk --no-cache add bash g++ openssl git
RUN go get -u github.com/mitchellh/gox

ENV SWAGGER_VERSION=v0.25.0

ENV REPO="github.com/go-swagger/go-swagger/cmd/swagger"
RUN go get -u "${REPO}"
WORKDIR /go/src/github.com/go-swagger/go-swagger
RUN git checkout "${SWAGGER_VERSION}"
RUN gox --osarch "linux/amd64" -output /swagger \
      -ldflags "-s -w -X ${REPO}/commands.Version=${SWAGGER_VERSION} -X ${REPO}/commands.Commit=$(git rev-parse --short HEAD)" \
      "${REPO}"

FROM alpine:3.12
COPY --from=build /swagger /usr/bin/swagger
ENV GOPATH=/go
WORKDIR /go/src
ENTRYPOINT ["swagger"]
CMD ["-h"]
