## User Guide: WAVE DPCTF Test Suite Using Windows + WSL

#### This guide explains how to use simple, interactive, automated scripts to install the WAVE DPCTF Test Suite on Windows with WSL using Ubuntu. The scripts enable the user to easily build, configure, run the tests, and analyze the results for users with minimal prior experience with Linux and WSL.

#### The Guide assumes the required software is already installed.
#### For details on installing the required software see:

	Clean uninstall_install of required packages.md

It provides a simple way to uninstall and reinstall the required packages. It can be found in the 'test_suite_scripts folder' at https://github.com/cta-wave/dpctf-deploy/tree/master. For additional details see also:

	https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md#part-i-installing-host-machine-required-software```

If you encounter problems with an install using the interactive scripts or prefer to manually install the Test Suite, see:

	https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md#part-ii-build-and-run-the-test-suite


#### OVERVIEW: Building and Running the WAVE DPCTF Test Suite

The initial build and test workflow consists of four steps:
- Build the Test Suite
- Configure the Test Environment
- Run a Test
- Analyze the Recording

Most users will only perform the build step once.

#### Required Software
* Windows 11
* WSL with Ubuntu
* Git for Ubuntu/WSL
* PowerShell
* Docker Engine for Ubuntu/WSL — NOT Docker Desktop

See above links for additional details.

##### Verify the Required software installation prior to building the WAVE Test Suite

To ensure installation was successful, run the following commands in a bash terminal:

	docker --version
	docker compose version

Both should return the version of the install.
If docker-compose is not installed, run:

	sudo apt-get update
	sudo apt-get install docker-compose-plugin

Then recheck the version to confirm it is installed.

##### To test if Docker is running correctly, in a bash terminal run:

	docker run hello-world

This command should return the message Hello from Docker

#### If it does not, or you get errors, review the installation of the required software at:

	https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md

### Important NOTE

At the end of the day, or if you will not be running tests for a prolonged period, it is highly recommended to stop all Docker containers in case the Host PC crashes or restarts, which can damage Docker containers.

To stop the containers run:

	docker-compose down

To restart the containers run:

	docker-compose up -d

#### Typical Daily Workflow

1. Run

		run_wave_admin.ps1
2. Follow the instructions shown in Notepad
3. Run the test
4. Record the Host (single device test) or DUT (2-device test) screen
5. Save the recording
6. Run

		bash analyse_wave_recordings.sh


#### Folder Structure

After setup, the following folder structure will exist on your machine:

''''
C:\\Users\<username>\
├─ test_suite_scripts\
│  ├─ build_wave_wsl.sh
│  ├─ run_wave_admin.ps1
│  ├─ analyse_wave_recordings.sh
│  ├─ 1_Device_Test_v1.md
│  ├─ 2_Device_Test_v1.md
│  ├─ 1_Device_Test_CURRENT.md
│  ├─ 2_Device_Test_CURRENT.md
│  ├─ WAVE_WSL_QuickStart_Guide.md
│  └─ WAVE_WSL_User_Guide.md
│
├─ dpctf-deploy\
│  ├─ config.json
│  ├─ docker-compose.yml
│  ├─ observation-config.ini
│  ├─ certs
│  ├─ results
│  ├─ test_recordings
│  ├─ test_recordings_backups
''''

&#x20;   | Folder | Description |
    |------|-------------|
    | test_suite_scripts | Automation scripts and guides — copied from the repo in Step 1 |
    | dpctf-deploy | Main WAVE Test Runner installation |
    | results | Stores test session results |
    | test\_recordings | Place recordings here before analysis — created automatically during build |
    | test\_recordings\_backups | Backup copies of original recordings — created automatically during build |


### FIRST TIME SETUP

Perform this section once when installing the test suite.

##### Step 1 — Get test_suite_scripts

Open Ubuntu from the Start Menu.

In the terminal, clone the repository. This is a lightweight download — it contains scripts, guides, and configuration files only. The large build downloads happen later when the build script runs.

	git clone https://github.com/cta-wave/dpctf-deploy.git ~/dpctf-temp

Copy the test_suite_scripts folder to your Windows user folder:

	cp -r ~/dpctf-temp/test_suite_scripts /mnt/c/Users/<your_username>/test_suite_scripts

Replace `<your_username>` with your Windows username. Example:

	cp -r ~/dpctf-temp/test_suite_scripts /mnt/c/Users/johndoe/test_suite_scripts

Remove the temporary clone — it is no longer needed:

	rm -rf ~/dpctf-temp

Verify the folder was created and contains the expected files:

	ls /mnt/c/Users/<your_username>/test_suite_scripts

You should see:

	build_wave_wsl.sh
	run_wave_admin.ps1
	analyse_wave_recordings.sh
	1_Device_Test_v1.md
	2_Device_Test_v1.md
	WAVE_WSL_QuickStart_Guide.md
	WAVE_WSL_User_Guide.md
    Clean uninstall_Install of required packages..md

If any files are missing, repeat the copy step above before continuing.

##### Step 2 — Build the Test Suite

In the same Ubuntu terminal, run the build script:

	bash /mnt/c/Users/<your_username>/test_suite_scripts/build_wave_wsl.sh <your_username>

Example:

	bash /mnt/c/Users/johndoe/test_suite_scripts/build_wave_wsl.sh johndoe

###### What the build script does

The script will automatically:

* Clone the dpctf-deploy repository into `C:\Users\<your_username>\dpctf-deploy\`
* Check out the selected branch and tag (if specified)
* Build the WAVE Test Runner
* Import test content
* Set EULA agreement in docker-compose.yml
* Optionally remove unused Docker volumes (if selected)
* Start the Docker containers
* Create the `test_recordings` and `test_recordings_backups` folders inside `dpctf-deploy`
* Copy test_suite_scripts to `C:\Users\<your_username>\test_suite_scripts\`

Note: The large downloads (test content, Docker images) occur during this step. Build time will vary depending on your internet connection speed but may take 15–30 minutes or more. Wait until it is complete.

###### Interactive Prompts During the Build

The script will prompt you for the following inputs as the build progresses. Press Enter to accept the default value shown in brackets, or type a value and press Enter.

**1. Branch** [default is master]

	Enter branch [master]:

Press Enter to use the default `master` branch, or type a specific branch name.

**2. Tag**

	Enter tag [leave blank for latest on master]:

Press Enter to use the latest available version on the selected branch. To install a specific release, type the tag (e.g. `v3.0.0`) and press Enter.

**3. EULA Agreement** — appears after import.sh completes

	Have you reviewed and agreed to the EULA? [y/N]:

The script displays the EULA link and requires confirmation before proceeding:

	https://github.com/cta-wave/dpctf-deploy/?tab=readme-ov-file#agree-to-the-eula

- Enter `y` to agree and continue. The script will set `AGREE_EULA: "yes"` in docker-compose.yml automatically.
- Press Enter or type `N` to decline. **The script will exit.** You must re-run and accept the EULA to continue.
- On a rebuild, if EULA was previously accepted, this prompt is skipped automatically.

**4. Docker volume prune** — appears after EULA, before containers start

	Run docker volume prune now? (y/N):

The script will ask if you want to remove unused Docker volumes from your system before starting the containers. This is optional cleanup.

- Enter `y` to remove unused volumes (affects all Docker projects on this machine, not only WAVE)
- Press Enter or type `N` to skip

If you are unsure, skip this step by pressing Enter.

###### When the build finishes

You should see:

	BUILD COMPLETE

The EULA has been accepted and the Docker containers are running. No further EULA action is required. Proceed directly to Step 3.

##### Step 3 — Configure the Test Runner

Open PowerShell as Administrator.

To do this:
1. Click Start
2. Search for PowerShell
3. Right-click
4. Select Run as Administrator

Change directory to the test_suite_scripts folder:

	cd "C:\Users\<your_username>\test_suite_scripts"

Include the quotation marks.

Run the configuration script:

	.\run_wave_admin.ps1

**Note:** The script displays an EULA reminder at startup. If the test runner appears non-functional after setup, verify that EULA was accepted during the build step.

###### What this script does

The script:

Prompts for:

- 1-device or 2-device test
- HTTP (host IP) or HTTPS (domain)

Then automatically:

- Detects Host IP
- Updates configuration
- Configures port forwarding
- Starts Docker containers
- Opens a live log window
- Generates test instructions

A Notepad window will open showing instructions for running a test. These instructions contain the correct URLs for the current network configuration.

#### Configure Access to the Test Runner

To allow the Test Runner to access other devices (2-Device Tests), use a Domain Name instead of an IP address, or for tests that require HTTPS with valid certificates, see:

	https://github.com/cta-wave/dpctf-deploy/tree/master?tab=readme-ov-file#configure-access-to-the-test-runner


#### Configure the Observation Framework

For additional details on configuring the Observation Framework see:

	https://github.com/cta-wave/dpctf-deploy/tree/master?tab=readme-ov-file#configure-the-observation-framework

**1-Device Testing**
- observation-config.ini is not required for 1-device/HTTP testing

**2-device HTTP testing**
- Created automatically if missing
- If an existing file is present it is preserved
- Only test_runner_url is updated

**HTTPS / Domain Mode**

Use only if BOTH devices:

- Resolve the domain to the Host IP
- Trust the certificate

Otherwise use HTTP / host IP.

##### Step 4 — Run a Test

###### NOTE: Before proceeding, and for additional details on how to record and run a test, see Phase 2:

	https://github.com/cta-wave/dpctf-deploy?tab=readme-ov-file#phase-2-test-execution-and-recording-to-be-performed-by-tester

Follow the instructions displayed in the Notepad window.

* The instructions contain the correct URLs to enter into a browser for the current network configuration and the type of test (1-Device or 2-Device) selected.

Two types of tests are supported:

* **Single Device Test:** One device is both the Host and the Device Under Test (DUT).

  * The host controls the test. Once the test begins a second tab opens and displays the video for recording.

  NOTE: Switch to the second tab IMMEDIATELY when the test begins and IMMEDIATELY begin recording it for later analysis. STOP recording when the test is complete.

* **Two Device Test:** This test uses two devices: a Host (PC) and a Device Under Test (DUT).

  * The Host PC controls the test.
  * The test video is displayed by the DUT (Phone / Tablet / TV) for recording on a separate device (camera or phone camera).

  NOTE: Start recording the DUT screen IMMEDIATELY when the test begins and stop recording when the test is complete.

##### Step 5 — Record and Save the Test Video

* After the test finishes, stop recording.
* Transfer and save the video to:

		C:\Users\<your_username>\dpctf-deploy\test_recordings\

Supported formats:

	.mp4
	.mov

##### Step 6 — Analyze the Recording

* Open Ubuntu from the Start Menu.

		cd /mnt/c/Users/<your_username>/test_suite_scripts

* Run the analysis script:

		bash analyse_wave_recordings.sh

**First run:** The script checks for the Device Observation Framework (DOF) Docker image. If not found, it will offer to build it automatically before proceeding. This only happens once — on subsequent runs the image is already present and analysis begins immediately.

The script will:

* Check for and optionally build the DOF image (first run only)
* Display available recordings
* Prompt you to select a file
* Allow optional analysis settings
* Back up the original recording to `dpctf-deploy/test_recordings_backups`
* Run the Device Observation Framework

The original recording:

		IMG_3824.mp4

becomes:

		IMG_3824_dpctf_<token>.mp4
		IMG_3824_dpctf_<token>.wav

The `<token>` identifies the test session.

#### Daily Workflow

The build step only needs to be performed once unless updating the test suite.

After the first build, the normal workflow is:

Run in PowerShell as Administrator:

	run_wave_admin.ps1

Follow the Notepad instructions, run a test, and analyze the recording.

#### Rebuilding the Test Suite

Rebuild when:

* Switching repository branches
* Updating to a new release
* Rebuilding Docker images

To rebuild, run in a terminal:

	bash /mnt/c/Users/<your_username>/test_suite_scripts/build_wave_wsl.sh <your_username>

The script will prompt you for the branch and tag, making it straightforward to target a specific release without editing the script. If EULA was previously accepted, that step is skipped automatically.

Then re-run in PowerShell as Administrator:

	run_wave_admin.ps1

#### Troubleshooting

Key Notes:
- Use a 1-device test first after build to verify the setup
- Prefer HTTP unless HTTPS is fully configured on all devices
- Verify the Test Runner URL loads in a browser before starting a test

If the test fails to run, stalls, or appears not to complete:

* Allow the test to run until it times out or returns "completed" — this can take several minutes.
* Retry the test.
* Try using a different browser.
* Restart the container and repeat the test. Open Ubuntu and run:

		cd /mnt/c/Users/<your_username>/dpctf-deploy
		docker-compose down
		docker-compose up -d

* View container logs for additional information:

		docker logs dpctf

* Verify test runner URLs are correct.

  For HTTP:

		http://<host_ip>:8000/_wave/index.html

  For HTTPS:

		https://dpctf.local:8443/_wave/index.html

##### Full Docker Reset

If containers fail to start, or an image is missing or damaged, and restarting containers (above) does not fix it, do a full reset before rebuilding rather than trying to fix individual pieces. This is most often needed after the Host PC lost power or crashed while Docker was running.

**1. Stop all running containers:**

	docker stop $(docker ps -a -q)

**2. Remove all stopped containers:**

	docker container prune

**3. Remove all images:**

	docker image prune -a

**Note:** This is different from the "docker volume prune" prompt in the build script below — that only clears persisted data volumes, not images, and won't fix a damaged or missing image on its own.

**4. Rebuild the Test Suite.** See "Rebuilding the Test Suite" above (Step 2), and answer "y" when asked to run `docker volume prune` for a complete reset. The rebuild also rebuilds the DOF image automatically — no separate manual step is needed.

For additional troubleshooting assistance, or to build the test suite manually from scratch, see:

	https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md

	https://github.com/cta-wave/dpctf-deploy?tab=readme-ov-file#getting-started-with-wave-streaming-media-test-suite---devices
