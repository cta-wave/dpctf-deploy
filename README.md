# Getting started with "WAVE Streaming Media Test Suite - Devices"

Linux system is highly recommended for this guide, use other systems at your own risk. 

There are three phases:

1. [Deployment](#phase-1-deployment-of-the-test-runner) (one time action, to be performed by IT personnel)
   - [Host machine requirements](#host-machine-requirements)
   - [Clone repository](#clone-repository)
   - [Build the image and download content](#build-the-image-and-download-content)
   - [Configure access to the test runner](#configure-access-to-the-test-runner)
     - [With IP address](#with-ip-address)
     - [With domain](#with-domain)
   - [Agree to the EULA](#agree-to-the-eula)
   - [Start the test runner](#start-the-test-runner)
   - [Update test runner](#update-test-runner)
   - [Use specific version](#use-specific-version)
2. [Test execution and recording](#phase-2-test-execution-and-recording) (to be performed by tester)
3. [Observation](#phase-3-analyse-recording-using-device-observation-framework) (analysis of recording to be performed by tester or other person)
   - [Clone repository](#clone-repository-1)
   - [Build the image](#build-the-image)
   - [Configure the Observation Framework](#configure-the-observation-framework)
   - [Running the analysis](#running-the-analysis)
   - [Getting the analysis results](#getting-the-analysis-results)
   - [Update observation framework](#update-observation-framework)
   - [Use specific version](#use-specific-version-1)
   - [Debugging](#debugging)

> [!TIP]
> **For Windows with WSL2 only**: The simplest way to build the "WAVE Streaming
> Media Test Suite – Devices" on a Windows with WSL2 platform is to follow the
> instructions in the
> [WAVE WSL QuickStart Guide](test_suite_scripts/WAVE_WSL_QuickStart_Guide.md)
> ([PDF version](test_suite_scripts/WAVE_WSL_QuickStart_Guide.pdf?raw=true)).
> For detailed instructions, including how to do a clean install of the software
> required to build and run the Test Suite, see the
> [WAVE WSL User Guide](test_suite_scripts/WAVE_WSL_User_Guide.md)
> ([PDF version](test_suite_scripts/WAVE_WSL_User_Guide.pdf?raw=true)).
> All scripts and guides referenced above are in the `test_suite_scripts`
> folder, which is included when you clone this repository.

## Phase 1: Deployment of the test runner (one time action, to be performed by IT personnel)

### Host machine requirements

- on Linux, macOS and Windows with WSL2:
  - docker
  - docker-compose
  - git
- TLS server certificate for a domain that can be resolved by the device under test (we use `yourhost.domain.tld` for the domain)
  Note: While some tests can be run without this, valid certificates are needed for tests of EME and encrypted content.
- camera that records at 120 fps or more (AVC/h.264)

Note: The test suite has been installed and run on other host machines with varying degrees of success. On Windows, it has been used with the free version of docker running in WSL2. It has been used on a Mac. No support or assistance is available for either of these or anything else similar. Neither of these should be attempted unless you know what you are doing or have access to someone who does. It is critical to ensure that the test runner can be contacted from the device under test and from the observation framework. This may be problematic with some combinations of virtualization technologies and network configurations.

### Device under test requirements

The device under test ("DUT") needs at least one mechanism for showing an arbitrary URL in the browser to be tested. These mechanisms may be standard (e.g. including the URL in a broadcast signal) or private / proprietary.
Note: If the DUT supports HbbTV then one possibility is to build an MPEG-2 transport stream containing the URL. One resource that may help with this specific case is https://github.com/ebu/hbbtv-dvbstream .

### Clone repository

> [!NOTE]
> If you already cloned the repository you can skip this step

Using the git command line tool, you can download the current version of the dpctf-deploy repository to your system:

```sh
git clone https://github.com/cta-wave/dpctf-deploy
```

Now all files necessary to setup the test runner are located in the `dpctf-deploy` directory. All following actions will be performed in here.

### Build the image and download content

To build the image run the build script in the `dpctf-deploy` directoy:

```sh
make build
```

Download test content to serve locally (note: this pulls a lot of data and may take a while):

```sh
make import-content
```

### Configure access to the test runner

The test runner can be configured to be accessed by either an IP or a domain. Setting up the access with an IP address is a lot easier than with domain, however, https tests only work with a valid certificate on TVs. It is recommended to only use IP address access for debugging the setup.

#### Windows WSL Proxy

> [!NOTE]
> You can skip this step if you are using Docker-Desktop or don't use Windows at all

In order to make the test runner accessible for other devices in the network some extra steps are required. All commands have to be run in the Windows Powershell.

> [!CAUTION]
> The Windows Powershell has to be run with Admin Priviliges **as Admin User**!

1. Run `wsl hostname -I` and copy the (first) IP address e.g. 172.24.202.133 (lets call this <wsl_ip>)
2. Run
   - `netsh.exe interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=<wsl_ip>`
   - `netsh.exe interface portproxy add v4tov4 listenport=8443 listenaddress=0.0.0.0 connectport=8443 connectaddress=<wsl_ip>`

#### With IP address

Note: When using an IP address https tests won't work.

In the `dpctf-deploy` directory open `config.json` and enter your host IP address in the `host_override` field:

`dpctf-deploy/config.json`

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
    "host_override": "192.168.1.23"
```

#### With domain

In the `dpctf-deploy` directory open `config.json` and enter your host domain or IP address in the `host_override` field

`dpctf-deploy/config.json`

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

Some tests require a DNS entry and valid certificates to execute correctly. For this please copy the domain's certificate into the `certs` directory. Finally, the certificates must be configured by adding following at same level as "wave" field, note that the key and pem files must be named according to your needs:

Running https tests requires a valid certificate for your domain. Copy your certificates files into the `certs` directory inside the `dpctf-deploy` directory:

`dpctf-deploy/certs`

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

`dpctf-deploy/config.json`

```json
{
  "browser_host": "web-platform.test",
  "alternate_hosts": {
    "alt": "not.web-platform.test"
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

### Agree to the EULA

For the test runner to start you are required to agree to the [EULA](./End-User-License-Agreement.md).

Set `AGREE_EULA` to `yes`:

`dpctf-deploy/docker-compose.yml`

```yml
environment:
  AGREE_EULA: "yes"
```

### Start the test runner

To start the test runner, change into the `dpctf-deploy` directory and run:

```sh
docker compose up
```

Wait until all http and https are started. The output should like something like this:

```sh
dpctf  | INFO:web-platform-tests:Starting https server on web-platform.test:*
dpctf  | INFO:web-platform-tests:Starting http server on web-platform.test:*
```

You are now able to open up the landing page of the test runner in your web browser:

```
http://yourhost.domain.tld:8000/_wave/index.html
```

or

```
http://<ip>:8000/_wave/index.html
```

If the command terminates or you see an error like the following, something went wrong with the startup:

```sh
dpctf exited with code 1
```

### Update test runner

To update the test runner to the latest version enter the deploy repository and pull the latest changes:

```sh
git pull origin master
```

Then rebuild the image:

```sh
make clean build
```

### Use specific version

> [!CAUTION]
> While we recommend using the latest version of the test suite for the most up-to-date features and fixes, you can also install previous releases if needed. To do so, visit the [releases](https://github.com/cta-wave/dpctf-deploy/releases) page and select the version (tag) you wish to install — e.g.,`v2.1.0`.

To use a specific release of the test suite, enter the deploy repository and checkout the version (tag) of the release (e.g. `v2.1.0`) you selected from the [releases](https://github.com/cta-wave/dpctf-deploy/releases) page:

```sh
git checkout v2.1.0
```

Then rebuild the image:

```sh
make clean build
```


## Phase 2: Test execution and recording (to be performed by tester)

> [!NOTE]
> Where browsers support installation of extensions, some such extensions may interfere with the test. If the video fails to start and run on the DUT browser with extensions installed, turn off the browser extensions on the DUT and repeat the test.

To execute tests, open the landing page on the DUT using the following URL:

```
http://yourhost.domain.tld:8000/_wave/index.html
```

or if you have provided valid certificates

```
https://yourhost.domain.tld:8443/_wave/index.html
```
#### Camera requirements:
The camera needs to be capable of recording video at around 120Hz, full HD. It needs to be capable of wired connection from DUT to record audio at 48kHz, 16-bits jointly with video. When getting started with the WAVE device test suite, the following may be useful purely for experimentation and familiarization with the test runner and test suite.
* It is possible to use cameras only recording at 60Hz if you limit yourself to experimenting with those tests where the video frame rate is 25/30Hz.
* If the camera records audio at 44.1 kHz and not 48kHz then either ffmpeg can be used to remove the 44.1kHz audio track or it may be possible to disable the camera recording audio. Disabling the microphone may only result in silence being recorded at 44.1kHz. Removing the audio would mean limiting yourself to experimenting with video only test and video observations for video and audio combined tests.

#### The tester must execute following steps

1. position video recording device in front of the display of DUT
   Note: Significant care is needed. Please see [documentation for obtaining recordings](https://github.com/cta-wave/device-observation-framework/blob/main/README.md#obtain-recording-files).

2. Either use a phone to scan the QR-Code -> test runner companion screen will open in phones's Web browser or
   Note the first 8 characters of the token from the landing page. Using a web browser (e.g. on the test runner PC), go to http://yourhost.domain.tld:8000/_wave/configuration.html and enter those 8 characters in the "Session token" box.

3. select the tests to be executed on DUT from provided lists
   Note: A good place to start for first time users would be to deselect all test groups by using the "None" button and then select one simple test, e.g. by expanding either cfhd_12.5_25_50-local or cfhd_15_30_60-local and then selecting just the sequential track playback test with stream t1 as shown.
4. start recording on recording device
5. press "Start session" button -> the test(s) should start to execute on DUT
6. once "Session completed" screen is visible on DUT then stop the recording
7. save link to testing session including the session token for later reference and report

## Phase 3: Analyse recording using device observation framework

The Observation Framework (OF) analyzes the video file recorded in phase 2 and automatically adds the results to the existing results of the corresponding session. Just like the Test Runner, the Observation Framework is setup in a docker container.

### Clone repository

> [!NOTE]
> If you already cloned the repository you can skip this step

Using the git command line tool, you can download the current version of the dpctf-deploy repository to your system:

```sh
git clone https://github.com/cta-wave/dpctf-deploy
```

Now all files necessary to setup the test runner are located in the `dpctf-deploy` directory. All following actions will be performed in here.

### Build the image

To build the image run the build script in the `dpctf-deploy` directoy:

```sh
./build-dof.sh
```

### Configure the Observation Framework

> [!NOTE]
> This step is only needed if you want to change the default Observation Framework configurations. For example, this is necessary if the Observation Framework and the Test Runner are not running on the same host.

To configure the Observation Framework, create a file named `observation-config.ini` in the root directory of this repository (`dpctf-deploy`). Copy and paste the content from `config.ini` located in the [Observation Framework's repository](https://github.com/cta-wave/device-observation-framework/blob/v2.1.0/config.ini). You can then make any necessary changes to `observation-config.ini`.

Usualy, the only configuration parameter you need to change is `test_runner_url`. This allows the Observation Framework to send results to your Test Runner if it is running on a different host. To do this, set the correct URL of the Test Runner in the `observation-config.ini` file:

```ini
test_runner_url = http://yourhost.domain.tld:8000/_wave/
```

### Running the analysis

Run the analysis by executing the `analyse-recording` script:

```sh
./analyse-recording.sh <mp4-filepath> <options>
```

> [!NOTE]
> If you get permission denied error, please use `sudo`!

For additional options please refer the [the documentation](https://github.com/cta-wave/device-observation-framework/blob/v2.1.0/README.md#additional-options)

### Getting the analysis results

If configured correctly in the step [Configure the Observation Framework](#configure-the-observation-framework), the results of the analysis are now available in the Test Runner's session:

```
http://yourhost.domain.tld:8000/_wave/results.html?token=SESSIONTOKEN
```

The results are also located in the `dpctf-deploy/observation-results` directory.

### Use specific version

> [!CAUTION]
> While we recommend using the latest version of the test suite for the most up-to-date features and fixes, you can also install previous releases if needed. To do so, visit the [releases](https://github.com/cta-wave/dpctf-deploy/releases) page and select the version (tag) you wish to install — e.g.,`v2.1.0`.

To use a specific release of the test suite, enter the deploy repository and checkout the version (tag) of the release (e.g. `v2.1.0`) you selected from the [releases](https://github.com/cta-wave/dpctf-deploy/releases) page:

```sh
git checkout v2.1.0
```

Then rebuild the OF image:

```sh
./build-dof.sh --reload-dof
```

### Debugging

If the observation framework reports errors and/or that the device has failed, some information on analysis and debugging can be found at https://github.com/cta-wave/device-observation-framework/wiki/Debugging-Observation-Failures
