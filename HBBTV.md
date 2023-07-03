# Getting started

## Deploying the test runner

### 0. Requirements

- software on host machine:
  - docker
  - docker-compose
  - git
  - python 3
- domain with certificate (we use `my.domain` in this document)
- camera that records at 120 fps or more

### 1. Clone deploy repository

Clone the DPCTF deploy repository and change to hbbTV branch:

```sh
$ git clone https://github.com/cta-wave/dpctf-deploy
```

Change to the cloned directory:

```sh
$ cd dpctf-deploy
```

Change to hbbTV branch:

```sh
$ git checkout hbbtv
```

### 2. Build the image and download content

To build the image, change into the repository's directory and run:

```sh
$ sudo ./build.sh master latest --tests-branch hbbtv-tests
```

Download test content:

```sh
$ ./import.sh
```

### 3. Configure test runner with domain

From the deploy repository's cloned directory, open `config.json` and change

```json
{
  "browser_host": "web-platform.test",
}
```

to have your domain configured, like

```json
{
  "browser_host": "my.domain",
}
```

Next, copy the domain's certificate into the `certs` directory.

### 4. Start the test runner

To start the test runner, change into the deploy repostory's clone directory and run:

```sh
$ sudo docker-compose up
```

### 5. Executing tests on the TV

To execute tests, open the landing page on the TV using the following URL: 

```
http://my.domain/_wave/index.html
```

Use a phone to scan the QR-Code and select the tests you want to run on the device. Press "Start session" to start the test run on the device.

### 6. Evaluate recordings
