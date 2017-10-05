# glide v0.x
#
# docker run --rm supinf/glide:0.x
# docker run --rm -v $GOPATH/src:/go/src -w /go/src/github.com/your-account/project supinf/glide:0.x install

FROM supinf/go:1.9-builder

ENV GLIDE_VERSION=0.12.3

RUN apk --no-cache add git 
RUN apk --no-cache add --virtual build-dependencies wget \
  && wget -q https://github.com/Masterminds/glide/releases/download/v${GLIDE_VERSION}/glide-v${GLIDE_VERSION}-linux-amd64.tar.gz \
  && tar xvf glide-v${GLIDE_VERSION}-linux-amd64.tar.gz -C /tmp \
  && mv /tmp/linux-amd64/glide /usr/bin/ \
  && apk del --purge build-dependencies \
  && rm -rf /tmp/linux-amd64

WORKDIR /go/src

ENTRYPOINT ["glide"]
CMD ["--help"]
