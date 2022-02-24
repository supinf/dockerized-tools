# AWS-CLI v2.4.20
# docker run --rm ghcr.io/supinf/awscli:2.4.20 --version
# docker run --rm -v $HOME/.aws:/root/.aws ghcr.io/supinf/awscli:2.4.20 sts get-caller-identity
# docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION ghcr.io/supinf/awscli:2.4.20 sts get-caller-identity

FROM alpine:3.12
ENV AWS_DEFAULT_REGION=ap-northeast-1 \
    AWS_PAGER=""
RUN apk --no-cache add tini bash jq python3 groff
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

ENTRYPOINT ["tini", "--", "aws"]
CMD ["help"]
