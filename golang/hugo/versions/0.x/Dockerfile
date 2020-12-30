# hugo v0.x
# docker run --rm ghcr.io/supinf/hugo:0.79 version
# docker run --rm -it -v $(pwd):/app ghcr.io/supinf/hugo:0.79 new site www
# docker run --rm -it -v $(pwd)/www:/app -p 80:80 ghcr.io/supinf/hugo:0.79 server --bind=0.0.0.0 -p=80 --appendPort=false

FROM alpine:3.12

ENV HUGO_VERSION=0.79.1

RUN apk --no-cache add tini

RUN apk --no-cache add --virtual build-dependencies wget ca-certificates \
  && wget -q https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && tar xvf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C /tmp \
  && mv /tmp/hugo /usr/bin/hugo \
  && apk del --purge build-dependencies \
  && rm -rf /tmp/*

WORKDIR /app

ENTRYPOINT ["/sbin/tini", "--", "hugo"]
CMD ["--help"]
