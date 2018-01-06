# flyway v5.0
#
# docker run --rm -v $(pwd)/conf:/flyway/conf supinf/flyway:5.0 info
# docker run --rm -v $(pwd)/conf:/flyway/conf -v $(pwd)/migrations:/flyway/sql supinf/flyway:5.0 migrate
# docker run --rm -v $(pwd)/conf:/flyway/conf -v $(pwd)/migrations:/flyway/sql -e FLYWAY_JAVA_OPTS="-Xms512m -Xmx2048m" supinf/flyway:5.0 migrate

FROM java:openjdk-8-jre-alpine

ENV FLYWAY_VERSION=5.0.5

ADD flyway /usr/bin/

RUN apk --no-cache add bash
RUN apk --no-cache add --virtual build-deps curl \
    && chmod +x /usr/bin/flyway \
    && repo="https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline" \
    && curl --location --silent --show-error --out /flyway.tar.gz \
        ${repo}/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
    && sha1="7f8bb77e77dde723f0dbbfe03aed7b3991afbdc0" \
    && echo "$sha1  flyway.tar.gz" | sha1sum -c - \
    && tar xzf /flyway.tar.gz \
    && mv /flyway-${FLYWAY_VERSION} /flyway \
    && rm -rf /flyway.tar.gz \
    && apk del --purge -r build-deps

WORKDIR /flyway

ENTRYPOINT ["flyway"]
CMD ["-v"]
