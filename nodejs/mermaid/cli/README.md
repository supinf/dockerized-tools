# Mermaid CLI

https://github.com/mermaidjs/mermaid.cli

[![supinf/mermaid-cli](http://dockeri.co/image/supinf/mermaid-cli)](https://hub.docker.com/r/supinf/mermaid-cli)

## Supported tags and respective `Dockerfile` links

・latest ([nodejs/mermaid/cli/versions/0.5/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/nodejs/mermaid/cli/versions/0.5/Dockerfile))  
・0.5 ([nodejs/mermaid/cli/versions/0.5/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/nodejs/mermaid/cli/versions/0.5/Dockerfile))  

## Usage

```
$ docker run --rm supinf/mermaid-cli:0.5
```

If you want to specify spec file,

```
# docker run --rm -v $(pwd):/work supinf/mermaid-cli:0.5 -i input.mmd -o output.pdf
# docker run --rm -v $(pwd):/work supinf/mermaid-cli:0.5 -i input.mmd -o output.png -b transparent
# docker run --rm -v $(pwd):/work supinf/mermaid-cli:0.5 -i input.mmd -o output.svg -w 1024 -H 768
```
