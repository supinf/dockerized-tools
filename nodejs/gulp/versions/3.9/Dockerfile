# Gulp v3.9.1

FROM node:7.7.1-alpine

ENV GULP_VERSION=3.9.1 \
    DOCKER_VERSION=1.13.0

RUN apk --no-cache add tini ca-certificates \

    # Install Gulp
    && npm install --global "gulp@${GULP_VERSION}" \

    # Clean up
    && rm -rf /root/.npm \
    && find / -depth -type d -name test* -exec rm -rf {} \; \
    && find / -depth -type f -name *.md -exec rm -f {} \; \
    && find / -depth -type f -name *.yml -exec rm -f {} \;

RUN apk --no-cache add --virtual build-deps curl \

    # Install Docker
    && curl --location --silent --show-error -O \
        https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz \
    && tar xzf docker-${DOCKER_VERSION}.tgz \
    && cp docker/docker /usr/bin/docker \

    # Clean up
    && rm -rf /docker* \
    && apk del --purge -r build-deps

WORKDIR /gulp

ADD package.json /gulp/package.json

RUN apk add --no-cache --virtual build-deps make g++ python-dev \
    && npm install \
    && apk del --purge -r build-deps

VOLUME /monitor
ADD sample-gulpfile.js /gulp/gulpfile.js
ADD sample-eslint.json /gulp/eslint.json

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["gulp"]
