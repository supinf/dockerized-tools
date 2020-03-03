# CFn-Lint v0.28
# docker run --rm supinf/cfn-lint:0.28
# docker run --rm -v "$(pwd)":/work supinf/cfn-lint:0.28 **/*.yaml

FROM alpine:3.10

RUN apk --no-cache add python py-setuptools
RUN apk --no-cache add --virtual build-deps py-pip \
    && pip install 'cfn-lint==0.28.2' \
    && apk del --purge -r build-deps

WORKDIR /work

ENTRYPOINT ["cfn-lint"]
CMD ["--help"]
