# Go Meta Linter

https://github.com/alecthomas/gometalinter

## Supported tags and respective `Dockerfile` links:

・latest ([golang/gometalinter/versions/2.0/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/golang/gometalinter/versions/2.0/Dockerfile))  
・2.0 ([golang/gometalinter/versions/2.0/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/golang/gometalinter/versions/2.0/Dockerfile))  


## Usage

### Configure

```
$ cat << EOF > lint-config.json
{
  "Enable": [
    "megacheck",
    "ineffassign",
    "misspell",
    "nakedret",
    "gas",
    "golint",
    "goconst",
    "unused",
    "deadcode",
    "vet",
    "gosimple"
  ],
  "Vendor": true,
  "Deadline": "60s",
  "Aggregate": true
}
EOF
```

### Test

```
$ docker run --rm \
    -v $(pwd):/go/src/github.com/your-name/project \
    -w /go/src/github.com/your-name/project \
    supinf/gometalinter:2.0 --config=lint-config.json ./...
```
