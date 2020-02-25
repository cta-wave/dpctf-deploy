# DPCTF test runner docker image

This repository contains configuration files to build a docker image and run 
it in a container with proper configuration.

## Create Image

To build the image, simply run

```shell
# ./build.sh <commit-id/branch/tag> <image-version>
```

In this command **commit-id/branch/tag** specifies what code base to use 
from the [WMAS repository](https://github.com/cta-wave/WMAS) in the created 
image. As indicated, this can be a commit id, a branch name or a tag. 
**image-version** specifies the version string the created docker image is 
tagged with. This allows to have multiple image with different versions.

For example:

```shell
# ./build.sh dpctf-v0.0.0 0.0.0
```

This will create a docker image for the code base tagged with "dpctf-v0.0.0" 
and sets the version tag to "0.0.0".

## Running the created image in a container

Running the created image in a properly configured container set the desired image version:

```yaml
services:
  dpctf:
    container_name: dpctf
    image: dpctf:0.0.0
```

**container_name** defines the name of the container, so we can later 
reference it when using docker commands specific to containers like start, 
stop, view logs and so on. **image** specifies what image to use to create the 
container. In this example, we use the version string of the example from the 
section "Create Image". The file contains further configurations, but for now 
this should be enough.

To then start the container run the following command:

```shell
# docker-compose up -d
```

This will use the configuration in the `docker-compose.yml` to create a new 
container and run it in the background.

The test runner can be configured using the `config.json`. All test results 
will be stored in the `results` directory.

## Controlling the running container

You can control the running container using a set of commands, which receive 
the name of the container you want to perform the action on.

Start container

```shell
# docker start <container_name>
```

Stop container

```shell
# docker stop <container_name>
```

View logs

```shell
# docker logs <container_name>
```

In our case, **container_name** is `dpctf`, unless it was changed in the `docker-compose.yml`.
