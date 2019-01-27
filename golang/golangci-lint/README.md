# GolangCI-Lint

github.com/golangci/golangci-lint

## Supported tags and respective `Dockerfile` links

・latest ([golang/golangci-lint/versions/1.12/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/golang/golangci-lint/versions/1.12/Dockerfile))  
・1.12 ([golang/golangci-lint/versions/1.12/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/golang/golangci-lint/versions/1.12/Dockerfile))  
・1.11 ([golang/golangci-lint/versions/1.11/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/golang/golangci-lint/versions/1.11/Dockerfile))  

## Usage

### Configure

```
$ cat << EOF > .golangci.yml
run:
  deadline: 3m
output:
  format: colored-line-number
  print-issued-lines: true
  print-linter-name: true
linters:
  disable-all: true
  enable:
    - golint
    - misspell
linters-settings:
  golint:
    min-confidence: 0.8
  misspell:
    locale: US
EOF
```

### Test

```
$ docker run --rm \
    -v $(pwd):/go/src/github.com/your-name/project \
    -w /go/src/github.com/your-name/project \
    supinf/golangci-lint:1.12 run --config .golangci.yml
```
