# AWS-CLI v1.16
# docker run --rm ghcr.io/supinf/awscli:1.18 --version
# docker run --rm -v $HOME/.aws:/root/.aws ghcr.io/supinf/awscli:1.18 sts get-caller-identity

FROM alpine:3.12

ENV PAGER=less \
    LESS="-eirMX"

RUN apk --no-cache add python3 less groff jq py3-six py3-urllib3 py3-colorama \
    && find / -depth -type d -name __pycache__ -exec rm -rf {} \; \
    && rm -rf /usr/share/terminfo

RUN apk --no-cache add --virtual build-deps py3-pip \
    && pip3 install 'awscli == 1.18.205' \
    && apk del --purge -r build-deps \
    && find / -depth -type d -name __pycache__ -exec rm -rf {} \; \
    && rm -rf /root/.cache /lib/apk/db

ENTRYPOINT ["aws"]
CMD ["help"]
