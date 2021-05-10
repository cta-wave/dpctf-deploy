# DPCTF test runner docker image

This repository contains configuration files to build a docker image and run 
it in a container with proper configuration.

## Requirements

- Docker (tested with v20.10.6)
- docker-compose (tested with v1.29.1)
- **Windows** and **Linux** require root/admin permissions for the provided commands. Please follow these instructions to run docker without root/admin:
  - [Run docker without root on Linux](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
  - [Run docker without admin on Windows](https://docs.docker.com/docker-for-windows/install/#install-docker-desktop-on-windows)

## Create Image

To build the image, simply run

```shell
./build.sh <commit-id/branch/tag> <image-version> [<options>]
```

In this command **commit-id/branch/tag** specifies what code base to use 
from the [DPCTF Test Runner repository](https://github.com/cta-wave/dpctf-test-runner) in the created 
image. As indicated, this can be a commit id, a branch name or a tag.

**image-version** specifies the version string the created docker image is 
tagged with. This allows to have multiple image with different versions.
The build script will name the image `dpctf:<image-version>`.

**options** - A list of optional arguments:
- **--reload-runner**: Reload the test runner, disabling cache
- **--reload-tests**: Reload test files, disabling cache

For example:

```shell
./build.sh master latest
```

To rebuild the image using the cache but retrigger the download of the tests, 
use the reload-tests argument:

```shell
./build.sh master latest --reload-tests
```

To rebuild the image using the cache but retrigger the download of the test 
runner, use the reload-runner argument:

```shell
./build.sh master latest --reload-runner
```

This will create a docker image for the latest code base on the master branch 
and sets the version tag to "latest". The resulting image will have the name
`dpctf:latest`.  
Please make sure to re-create the container (run `docker-compose up -d`) each time you create a new image. 

## Running the created image in a container

To run the created image in a properly configured container, set the desired image version:

`docker-compose.yml`
```yaml
services:
  dpctf:
    container_name: dpctf
    image: dpctf:latest
```

**container_name** defines the name of the container, so we can later 
reference it when using docker commands specific to containers like start, 
stop, view logs and so on. **image** specifies what image to use to create the 
container. In this example, we use the version string of the example from the 
section "Create Image". The file contains further configurations, but for now 
this should suffice.

Every directory mapped into the container has to have its owner set to user id
1000 in order for the test runner to perform read and write actions. (e.g. `results` directory)

To then start the container run the following command:

```shell
docker-compose up
```

This will use the configuration in the `docker-compose.yml` to create a new
container and run it.

Once the docker container is repeatedly running correctly, it may be run as a daemon using the `-d` flag:

```shell
docker-compose up -d
```

For more details on controlling the container when running it in the background, see the corresponding [section](#controlling-the-running-container).

The test runner can be configured using the `config.json`. For more details 
see the [docs](https://github.com/cta-wave/dpctf-test-runner/blob/master/tools/wave/docs/config.md).

All test results will be stored in the `results` directory.

## Mapping new content into the container

It may be useful to be able to use custom content with the test runner. This requires modification of the `docker-compose.yml` for any directory or file that should be mapped into the container.

Inside the `docker-compose.yml` under `volumes`, add a new line per file or directory to map:

```yaml
    volumes:
      - <src_host_path>:<dest_container_path>
```

The `src_host_path` can be an absolute or relative path. The `dest_container_path` should be `/home/ubuntu/DPCTF/<dest_name>`, to make it available for serving from the test runners web server.

For example, to map a new group of tests named 'test-group' and a custom `test-config.json`:

```
ls

docker-compose.yml
test-group
test-config.json
```

```yaml
    volumes:
      - ./test-group:/home/ubuntu/DPCTF/test-group
      - ./test-config.json:/home/ubuntu/DPCTF/test-config.json
```

Then restart the container using docker-compose command:

```
docker-compose up -d
```

Files are now accessible under the relative path to the test runner directory:

Test files inside 'test-group':
```
http://web-platform.test:8000/test-group/
```

`test-config.json`:
```
http://web-platform.test:8000/test-config.json
```

## Controlling the running container

You can control the running container using a set of commands, which receive 
the name of the container you want to perform the action on.

Start container

```shell
docker start <container_name>
```

Stop container

```shell
docker stop <container_name>
```

View logs

```shell
docker logs <container_name>
```

In our case, **container_name** is `dpctf`, unless it was changed in the `docker-compose.yml`.

## Running tests

In general, to access the test runners landing page, it can be accessed under the following URL:
```
http://<host-domain/ip>:<port>/_wave/index.html
```

- **host-domain/ip**: The domain or IP of the machine that hosts the DPCTF 
test runner. To access the host machine by its IP address, add the `host_override` 
parameter to the config.json. For more details see 
[the docs](https://github.com/cta-wave/dpctf-test-runner/blob/master/tools/wave/docs/config.md#210-host-override)
- **port**: The port number the DPCTF test runner is runner on (default port is `8000`)

Please also see the DPCTF section in the DPCTF Test Runner [Readme file](https://github.com/cta-wave/dpctf-test-runner#dpctf-info).
For further information on how to configure sessions and general usage see [the documentation](https://github.com/cta-wave/dpctf-test-runner/blob/master/tools/wave/docs/usage/usage.md) (please make sure that dpctf is selected when configuring a new session).

Additionally, it is possible to run tests using the [REST API](https://github.com/cta-wave/dpctf-test-runner/blob/master/tools/wave/docs/rest-api/README.md).

### Run on host machine

![Single Machine Setup](./same-machine-setup.jpg)

The most simple use case is to execute the test on the same machine as the 
DPCTF test runner is running on. 

1. Run the docker container on the host machine
2. Open the landing page `http://localhost:<port>/_wave/index.html` in Browser (As everything runs on the same machine, the host can be `localhost` used)
3. Use the "Configure Session" button on the landing page to configure and start the session

### Run on separate DUT (TV, Mobile, etc.)

![PC-DUT Setup](./pc-dut-setup.jpg)

Another common use case is to have a separate device under test, like a TV or 
mobile device, to run the tests on. 

1. Set the [`host_override`](https://github.com/cta-wave/dpctf-test-runner/blob/master/tools/wave/docs/config.md#210-host-override) parameter to the IP of the host  machine. 
2. Run the docker container on the host machine
3. Open the landing page `http://<host_ip>:<port>/_wave/index.html` on the DUT (TV, mobile, ...)
4. On the host machine open the URL `http://<host_ip>:<port>/_wave/configuration.html` and enter the session token displayed on the 
landing page (on TV or mobile) to configure and start the session.

### Run on separate DUT using companion device

![PC-DUT-Companion Setup](./pc-dut-companion-setup.jpg)

A companion device may be used to configure and manage a test session. In this 
setup, the test runner is hosted on one device, whereas another device is used 
to configure and monitor the test session that runs on the DUT. 

1. Set the [`host_override`](https://github.com/cta-wave/dpctf-test-runner/blob/master/tools/wave/docs/config.md#210-host-override) parameter to the IP of the host  machine. 
2. Run the docker container on the host machine
3. Open the landing page `http://<host_ip>:<port>/_wave/index.html` on the DUT (TV, mobile, ...)
4. Access configuration page to configure and start session using one of these options:
   * Open the URL `http://<host_ip>:<port>/_wave/configuration.html` and enter the session token displayed on the landing page
   * Scan the QR code displayed on the landing page

### Detailed Guides

- [Run tests on mobile](./MOBILE_USAGE.md)
