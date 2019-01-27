# ShellCheck

http://www.shellcheck.net

[![supinf/shellcheck](http://dockeri.co/image/supinf/shellcheck)](https://hub.docker.com/r/supinf/shellcheck)

## Supported tags and respective `Dockerfile` links

・latest ([haskell/shellcheck/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/haskell/shellcheck/versions/0.x/Dockerfile))  
・0.x ([haskell/shellcheck/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/haskell/shellcheck/versions/0.x/Dockerfile))  

## Usage

### Check shell scripts style

```
$ docker run --rm -it -v $(pwd):/work -e IGNORE_PATH=/vendor/ supinf/shellcheck
```
