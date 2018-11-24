# CoreOS/Clair v2.0
# docker run --rm supinf/clair:2.0

FROM golang:1.11.2-alpine3.8 AS build
ENV CLAIR_VERSION=v2.0.7 \
    REPO=github.com/coreos/clair
RUN apk add --no-cache git
RUN go get "${REPO}"
WORKDIR /go/src/github.com/coreos/clair
RUN git checkout "${CLAIR_VERSION}"
RUN go build -ldflags "-s -w -X ${REPO}/pkg/version.Version=${CLAIR_VERSION}" "${REPO}/cmd/clair"

FROM alpine:3.8
COPY --from=build /go/src/github.com/coreos/clair/clair /clair
RUN apk add --no-cache git rpm xz
CMD ["/clair"]
