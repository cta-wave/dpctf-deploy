# Quick Start guide for getting started with Wave Streaming Media Test Suite - Devices

Linux system is highly recommended for this guide, use other systems at your own risk.

There are three phases:
1. *Deployment* (one time action, to be performed by IT personel)
2. *Test execution and recording* (to be performed by tester)
3. *Observation* (analysis of recording to be performed by tester or other person)

## Phase 1: Deployment of the test runner

### Host machine requirements

- software on host machine:
  - docker
  - docker-compose
  - git (Windows note: all commands executed via "Git Bash")
- domain (we use `yourhost.domain.tld` in this document) with valid certificates are needed for some tests (EME, encrypted content)
- camera that records at 120 fps or more (AVC/h.264)

### Clone deploy repository

Clone the DPCTF deploy repository:

```sh
$ git clone https://github.com/cta-wave/dpctf-deploy
$ cd dpctf-deploy
```

### Build the image and download content

To build the image, change into the repository's directory and run

Linux:
```sh
$ ./build.sh master latest
```

Windows:
```console
.\build.bat master latest
```

Download test content to serve locally (note: this may take a while):

Linux:
```sh
$ ./import.sh
```

Windows:
```sh
.\import.bat
```

### Configure test runner with domain

In the `dpctf-deploy` directory open `config.json` and enter your host domain or IP address in the `host_override` field

```json
{
  "browser_host": "web-platform.test",
  "alternate_hosts": {
    "alt": "not.web-platform.test"
  },
  "wave": {
    "aliases": [],
    ....
    "api_titles": [],
    "host_override": "yourhost.domain.tld"
```

Note: When using an IP address https test won't work.

Some tests require a DNS entry and valid certificates to execute correctly. For this please copy the domain's certificate into the `certs` directory. Finally, the certificates must be configured by adding following at same level as "wave" field, note that the key and pem files must be named according to your needs:

Running https tests requires a valid certificate for your domain. Copy your certificates files into the `certs` directory inside the `dpctf-deploy` directory:

`dpctf-deploy/certs`:
```
cacert.pem
private.key
certificate.pem
```

Then copy the following configuration to the root of `config.json`
```json
  "ssl": {
    "type": "pregenerated",
    "encrypt_after_connect": false,
    "openssl": {
      "openssl_binary": "openssl",
      "base_path": "_certs",
      "force_regenerate": false,
      "base_conf_path": null
    },
    "pregenerated": {
      "ca_cert_path": "./certs/cacert.pem",
      "host_key_path": "./certs/private.key",
      "host_cert_path": "./certs/certificate.pem"
    },
    "none": {}
  },
```
Where `ca_cert_path`, `host_key_path` and `host_cert_path` have the correct file names of your certificate.

Your `config.json` should look something like this:

```json
{
  "browser_host": "yourhost.domain.tld",
  "alternate_hosts": {
    "alt": "not.yourhost.domain.tld"
  },
  "ssl": {
    "type": "pregenerated",
    "encrypt_after_connect": false,
    "openssl": {
      "openssl_binary": "openssl",
      "base_path": "_certs",
      "force_regenerate": false,
      "base_conf_path": null
    },
    "pregenerated": {
      "ca_cert_path": "./certs/cacert.pem",
      "host_key_path": "./certs/private.key",
      "host_cert_path": "./certs/certificate.pem"
    },
    "none": {}
  },
  "wave": {
    "aliases": [],
    "results": "./results",
    "timeouts": {
        "automatic": 100000,
        "manual": 100000
    },
    "enable_results_import": false,
    "web_root": "/_wave",
    "persisting_interval": 20,
    "api_titles": [],
    "host_override": "yourhost.domain.tld"
  }
}
```

### Start the test runner

To start the test runner, change into the cloned `dpctf-deploy` directory, agree to EULA (https://github.com/cta-wave/dpctf-deploy/#agree-to-eula) by setting `AGREE_EULA: "yes"` in docker-compose.yml and run:

```sh
$ docker-compose up
```

The output should show no errors like 
```sh
dpctf exited with code 1
```

And the endpoint `http://yourhost.domain.tld:8000/_wave/index.html` should be accessible by DUT, check e.g. in Web browser.


## Phase 2: Test execution and recording

### Executing tests on the TV

To execute tests, open the landing page on the TV using the following URL (e.g. by putting into your launcher): 

```
http://yourhost.domain.tld:8000/_wave/index.html

or https://yourhost.domain.tld:8443/_wave/index.html if you have provided valid certificates
```

The tester must execute following steps

1. position video recording device (e.g. smartphone with 120fps using AVC codec) in front of the display of DUT
2. use a phone to scan the QR-Code -> test runner companion screen will open in phones's Web browser
3. select the tests to be executed on DUT from provided lists
4. start recording on recording device
5. press "Start session" button -> the test(s) should start to execute on DUT
6. once "Session completed" screen is visible on DUT then stop the recording
7. save link to testing session including the session token for later reference and report

## Phase 3: Analyse recording using device observation framework

Following steps should be sufficient to get started with dockerized version, more details at https://github.com/cta-wave/device-observation-framework

Build the image:
```sh
$ ./build-dof.sh
```

Create or edit the `observation-config.ini` to point to the used test runner instance:

```ini
test_runner_url = http://yourhost.domain.tld
```

Run the analysis:
```sh
./analyse-recording.sh <mp4-filepath>
```

The observation framework will enrich the testing session with results automatically.

The final test results including video analysis results are available at 
```
http://yourhost.domain.tld:8000/_wave/results.html?token=SESSIONTOKEN
```

Export your test results into your archive.
