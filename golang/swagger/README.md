# go-swagger

github.com/go-swagger/go-swagger

## Supported tags and respective `Dockerfile` links

・latest ([golang/swagger/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/golang/swagger/versions/0.x/Dockerfile))  
・0.18.0 ([golang/swagger/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/golang/swagger/versions/0.x/Dockerfile))  

## Usage

```
$ docker run --rm \
    -v $GOPATH/src:/go/src \
    -w /go/src/github.com/your-account/project \
    supinf/go-swagger generate server -A sample -f ./swagger.yml
```
