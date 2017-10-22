# AWS CLI v1.11

FROM alpine:3.6

ENV PAGER='cat'

RUN apk --no-cache add python
RUN apk --no-cache add --virtual build-dependencies py2-pip \
      && apk --no-cache add groff jq \
      && pip install 'awscli == 1.11.175' \
      && apk del --purge -r build-dependencies

ENTRYPOINT ["aws"]
CMD ["--version"]
