# CFn-Lint v0.58
# docker run --rm ghcr.io/supinf/cfn-lint:0.58
# docker run --rm -v "$(pwd)":/work ghcr.io/supinf/cfn-lint:0.58 **/*.yaml

FROM alpine:3.12

RUN apk --no-cache add python3 py3-setuptools py3-urllib3
RUN apk --no-cache add --virtual build-deps py3-pip \
    && pip3 install 'cfn-lint==0.58.0' \
    && apk del --purge -r build-deps

WORKDIR /work

ENTRYPOINT ["cfn-lint"]
CMD ["--help"]
