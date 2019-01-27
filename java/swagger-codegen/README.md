# Swagger Codegen

https://github.com/swagger-api/swagger-codegen

[![supinf/swagger-codegen](http://dockeri.co/image/supinf/swagger-codegen)](https://hub.docker.com/r/supinf/swagger-codegen)

## Supported tags and respective `Dockerfile` links

・latest ([java/swagger-codegen/versions/2.3/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/java/swagger-codegen/versions/2.3/Dockerfile))  
・2.3 ([java/swagger-codegen/versions/2.3/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/java/swagger-codegen/versions/2.3/Dockerfile))  

## Usage

```
$ docker run --rm -it -v $(pwd):/src supinf/swagger-codegen:2.3 \
    generate -i /src/swagger.yaml -o /src/generated -l javascript
```
