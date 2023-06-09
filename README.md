## Introduction
Build docker image for [spug](https://github.com/openspug/spug) base on [python apline](https://hub.docker.com/_/python/) image.
> this image will use sqlite as the database, and change all directory of logs as volume.
> for the details, please refer to the source.

> you can find a image here at [docker hub](https://hub.docker.com/r/balder1840/gollum)

## How to use
```bash
   docker run -d \
   --name spug \
   -p 8080:80 \
   -v ~/spug/data:/app/data \
   -v ~/spug/logs:/app/logs \
   balder1840/spug-alpine:tagname
```

## Refs
- [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [docker buildx build](https://docs.docker.com/engine/reference/commandline/buildx_build/)
- [Leverage multi-CPU architecture support](https://docs.docker.com/desktop/multi-arch/)
- [Multi-Platform Docker Builds](https://www.docker.com/blog/multi-platform-docker-builds/)
- [Exports Overview](https://docs.docker.com/build/exporters/)
- [Image and registry exporters](https://docs.docker.com/build/exporters/image-registry/)
- [spug-service](https://github.com/liangwj72/spug-service)
- [spug-docker](https://github.com/quicklyon/spug-docker)
- https://cryptography.io/en/latest/installation
- https://www.python-ldap.org/en/latest/installing.html
- https://pip.pypa.io/en/stable/cli/pip_install/
- https://spug.cc/docs/deploy-product
