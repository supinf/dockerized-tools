# AWS-CLI v2.0
# docker run --rm supinf/awscli:2.0 --version
# docker run --rm -v $HOME/.aws:/root/.aws supinf/awscli:2.0 sts get-caller-identity
# docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION supinf/awscli:2.0 sts get-caller-identit

FROM alpine:3.12 AS build
ENV AWSCLI_VERSION="2.0.40"
RUN apk --no-cache add git build-base libffi-dev openssl-dev python3-dev py3-pip
RUN git clone --depth=1 -b "${AWSCLI_VERSION}" https://github.com/aws/aws-cli.git /opt/aws
WORKDIR /opt/aws
RUN pip install --ignore-installed -r requirements.txt
RUN pip install -e .
RUN find /usr/lib/ -depth -type d -name __pycache__ -exec rm -rf {} \;
RUN find /usr/lib/ -depth -type d -name "tests"  -exec rm -rf {} \;

FROM alpine:3.12
ENV AWS_DEFAULT_REGION=ap-northeast-1 \
    AWS_PAGER=""
RUN apk --no-cache add python3
COPY --from=build /usr/lib/python3.8/site-packages /usr/lib/python3.8/site-packages
COPY --from=build /usr/bin/aws /usr/bin/aws
COPY --from=build /opt/aws /opt/aws
ENTRYPOINT ["aws"]
CMD ["help"]
