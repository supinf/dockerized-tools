# AsyncAPI editor

https://github.com/asyncapi/editor

[![supinf/asyncapi-editor](http://dockeri.co/image/supinf/asyncapi-editor)](https://hub.docker.com/r/supinf/asyncapi-editor)

## Supported tags and respective `Dockerfile` links

・latest ([nodejs/asyncapi/editor/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/nodejs/asyncapi/editor/versions/0.x/Dockerfile))  
・0 ([nodejs/asyncapi/editor/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/nodejs/asyncapi/editor/versions/0.x/Dockerfile))  

## Usage

```
$ docker run --rm -p 3000:3000 supinf/asyncapi-editor:0
```

If you want to specify spec file,

```
$ docker run --rm -p 3000:3000 -v $(pwd):/app/public/spec supinf/asyncapi-editor:0
```
