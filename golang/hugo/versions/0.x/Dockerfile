# hugo v0.x
# docker run --rm supinf/hugo version
# docker run --rm -it -v $(pwd):/app supinf/hugo new site www
# docker run --rm -it -v $(pwd)/www:/app -p 80:80 supinf/hugo server --bind=0.0.0.0 -p=80 --appendPort=false

FROM alpine:3.5

ENV HUGO_VERSION=0.29

RUN apk --no-cache add tini

RUN apk --no-cache add --virtual build-dependencies wget ca-certificates \
  && wget -q https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && tar xvf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
  && mv hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64 /usr/bin/hugo \
  && apk del --purge build-dependencies

WORKDIR /app

ENTRYPOINT ["/sbin/tini", "--", "hugo"]
CMD ["--help"]
