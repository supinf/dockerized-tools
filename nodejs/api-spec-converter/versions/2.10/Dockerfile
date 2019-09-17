# LucyBot-Inc/api-spec-converter
#
# docker run --rm -t supinf/api-spec-converter:2.10
# docker run --rm -t -v $(pwd):/work supinf/api-spec-converter:2.10 --from=swagger_1 --to=swagger_2 spec.json
# docker run --rm -t -v $(pwd):/work supinf/api-spec-converter:2.10 --from=openapi_3 --to=swagger_2 --syntax=yaml spec.yaml

FROM node:12.10.0-alpine
# FROM node:12.10.0-stretch-slim

ENV APISPEC_CONVERTER_VERSION=v2.10.1

RUN yarn global add "api-spec-converter@${APISPEC_CONVERTER_VERSION}" \
    && rm -rf /usr/local/share/.cache \
    && find /usr/local/share/.config -depth -type d -name test -exec rm -rf {} \;

WORKDIR /work

ENTRYPOINT ["api-spec-converter"]
CMD ["--help"]
