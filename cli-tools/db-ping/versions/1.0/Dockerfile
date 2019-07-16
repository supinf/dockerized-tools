# DB ping
# it waits until the specified database gets active
#
# docker run --rm --network=host -e DB_USER -e DB_PASS -e DB_DATABASE supinf/dbping:1.0
# docker run --rm -e DB_TYPE=postgresql -e DB_HOST -e DB_PORT=5432 -e DB_USER -e DB_PASS -e DB_DATABASE supinf/dbping:1.0

FROM alpine:3.10

RUN apk --no-cache add "bash=5.0.0-r0" \
      "mariadb-client=10.3.16-r0" \
      "postgresql-client=11.4-r0"

ENV DB_TYPE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=root \
    DB_PASS= \
    DB_DATABASE=database \
    PING_TIMEOUT=30

WORKDIR /work

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
