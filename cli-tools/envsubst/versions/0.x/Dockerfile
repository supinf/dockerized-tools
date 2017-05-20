# envsubst
# docker run --rm -it -v $(pwd):/tmp -e ARG=arg supinf/envsubst /tmp/target.yml

FROM alpine:3.5

ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh \
    && apk --no-cache add gettext \
    && rm -rf /usr/share/terminfo

WORKDIR /work

ENTRYPOINT ["/entrypoint.sh"]
