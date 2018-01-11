# GoogleCloudPlatform/container-structure-test

https://github.com/GoogleCloudPlatform/container-structure-test

## Supported tags and respective `Dockerfile` links:

・latest ([cli-tools/container-structure-test/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/cli-tools/container-structure-test/versions/0.x/Dockerfile))  
・0.1 ([cli-tools/container-structure-test/versions/0.x/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/cli-tools/container-structure-test/versions/0.x/Dockerfile))  


## Usage

### Configure

```
$ mkdir config
$ cat << EOF > config/test.yaml
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
    -v $(pwd)/config:/config supinf/container-struct-test:0.1 \
    -image supinf/awscli:1.14 /config/test.yaml
```
