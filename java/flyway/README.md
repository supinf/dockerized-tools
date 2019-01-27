# Flyway

https://flywaydb.org/

[![supinf/flyway](http://dockeri.co/image/supinf/flyway)](https://hub.docker.com/r/supinf/flyway)

## Supported tags and respective `Dockerfile` links

・latest ([java/flyway/versions/5.2/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/java/flyway/versions/5.2/Dockerfile))  
・5.2 ([java/flyway/versions/5.2/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/java/flyway/versions/5.2/Dockerfile))  

## Usage

```
$ export FLYWAY_JAVA_OPTS="-Xms512m -Xmx2048m"
$ docker run --rm \
    -v $(pwd)/conf:/flyway/conf -v $(pwd)/migrations:/flyway/sql \
    -e FLYWAY_JAVA_OPTS supinf/flyway:5.2 migrate
```
