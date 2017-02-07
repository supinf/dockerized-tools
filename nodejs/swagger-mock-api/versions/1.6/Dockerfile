# swagger-mock-api v1.6.0
#
# docker run --rm -p 80:8000 supinf/swagger-mock-api
# docker run --rm -p 80:8000 -v `pwd`:/api supinf/swagger-mock-api

FROM alpine:3.5

ENV MOCKAPI_VERSION=1.6.0 \
    NODE_VERSION=7.2.1-r1

WORKDIR /server

RUN apk --no-cache add tini nodejs-current=${NODE_VERSION} \

    # Install Grunt packages
    && npm install --global "grunt-cli@1.2.0" \
    && npm install "grunt@1.0.1" \
    && npm install "grunt-contrib-connect@1.0.2" \

    # Install dzdrazil/swagger-mock-api
    && npm install "swagger-mock-api@${MOCKAPI_VERSION}" \

    # Clean up
    && rm -rf /root/.npm \
    && find / -depth -type d -name test* -exec rm -rf {} \; \
    && find / -depth -type f -name *.md -exec rm -f {} \; \
    && find / -depth -type f -name *.yml -exec rm -f {} \;

ADD Gruntfile.js /server/Gruntfile.js

# Add sample of API definitions
ADD petstore.yaml /api/swagger.yaml

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["grunt"]
