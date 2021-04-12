FROM alpine:3.13 AS certs
RUN apk --no-cache add ca-certificates

FROM golang:1.15.11-alpine3.13 AS build
RUN apk --no-cache add git
RUN go get -u github.com/aws/aws-xray-daemon/...
WORKDIR /go/src/github.com/aws/aws-xray-daemon
ENV XRAY_VERSION=3.2.0
RUN git checkout "${XRAY_VERSION}"
WORKDIR /go/src/github.com/aws/aws-xray-daemon/daemon
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64
RUN go build -ldflags "-s -w" -o /xray
RUN ln -sf /dev/stdout /var/log/xray-daemon.log

FROM scratch
EXPOSE 2000/tcp
EXPOSE 2000/udp
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /var/log /var/log
COPY --from=build /xray /usr/bin/
COPY xray-daemon.yaml /
ENTRYPOINT ["/usr/bin/xray", "--config", "/xray-daemon.yaml"]
CMD ["--region", "us-west-2"]