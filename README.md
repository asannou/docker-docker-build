```
$ docker run -it --rm -v /var/run/docker.sock:/docker.sock asannou/docker-build:run -it --rm -- asannou/docker-build-test arg
```

or

```
$ docker run -it --rm -v /var/run/docker.sock:/docker.sock asannou/docker-build asannou/docker-build-test
$ docker run -it --rm asannou/docker-build/asannou/docker-build-test arg
```
