# Redash

```
$ cat << EOF > docker-compose.yaml
version: "3.7"
services:
  redash:
    image: supinf/redash:5.0
    ports:
      - 5000:5000
      - 5432:5432
    restart: always
    container_name: redash

  backup:
    image: supinf/postgres-backup:9.5
    environment:
      POSTGRES_HOST: "redash"
      POSTGRES_USER: "postgres"
      POSTGRES_DATABASE: "postgres"
      SCHEDULE: "@daily"
      AWS_ACCESS_KEY_ID: "AKIAIOSFODNN7EXAMPLE"
      AWS_SECRET_ACCESS_KEY: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      S3_BUCKET: "foobar"
      S3_PREFIX: "backups/"
      RESTORE_AFTER: "30"
      RESTORE_FROM: "backups/dump.sql.gz"
    links:
      - redash:redash
    restart: always
    container_name: backup
EOF
$ docker-compose up
```
