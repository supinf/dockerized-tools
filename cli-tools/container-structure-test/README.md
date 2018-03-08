# GoogleCloudPlatform/container-structure-test

https://github.com/GoogleCloudPlatform/container-structure-test

## Supported tags and respective `Dockerfile` links:

・latest ([cli-tools/container-structure-test/versions/0.2/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/cli-tools/container-structure-test/versions/0.2/Dockerfile))  
・0.2 ([cli-tools/container-structure-test/versions/0.2/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/cli-tools/container-structure-test/versions/0.2/Dockerfile))  
・0.1 ([cli-tools/container-structure-test/versions/0.1/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/cli-tools/container-structure-test/versions/0.1/Dockerfile))  


## Usage

### Configure

```
$ cat << EOF > test.yaml
schemaVersion: '2.0.0'
fileExistenceTests:
- name: 'binary'
  path: '/usr/bin/aws'
  shouldExist: true
metadataTest:
  entrypoint: ["aws"]
  cmd: ["--version"]
  env:
    - key: PAGER
      value: less
  workdir: [""]
EOF
```

### Test

```
$ docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/config supinf/container-struct-test:0.2 \
    -image supinf/awscli:1.14 /config/test.yaml
```
