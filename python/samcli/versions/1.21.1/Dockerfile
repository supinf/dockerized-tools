FROM alpine:3.12

### awscli install #
ENV GLIBC_VER=2.31-r0
RUN apk --no-cache add \
    binutils \
    curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
    glibc-${GLIBC_VER}.apk \
    glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
    binutils \
    curl \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*
# awscli install ###

### samcli install #
ENV SAM_VERSION 1.21.1
RUN apk --no-cache add tini bash jq python3 groff py-pip \
    && apk add --no-cache --virtual build-dependencies gcc musl-dev python3-dev 
RUN pip install aws-sam-cli==${SAM_VERSION} \
    && apk del build-dependencies
# samcli install ###

ENV AWS_DEFAULT_REGION=ap-northeast-1 \
    AWS_PAGER=""

WORKDIR /var/opt
EXPOSE 3000

ENTRYPOINT ["tini", "--"]
CMD ["aws", "--version"]
