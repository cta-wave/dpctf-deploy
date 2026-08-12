## Quick Start Guide: WAVE DPCTF Test Suite Using Windows + WSL
### For more detailed instructions or if you are not familiar with Linux running under Windows with WSL see the WAVE_WSL_User_Guide.md or PDF in the test_suite_scripts folder.  
#### This QuickStart Guide explains how to use simple, interactive, automated scripts to install the WAVE DPCTF Test Suite on Windows with WSL using Ubuntu. The scripts enable the user to easily build, configure, run the tests, and analyze the results for users with minimal prior experience with Linux and WSL.
#### This Guide assumes the user is familiar with Linux Terminal and Windows WSL PowerShell
#### The Guide assumes the required software is already installed.
#### For details on installing the required software see:

	Clean uninstall_install of required packages.md

It provides a simple way to uninstall and reinstall the required packages. It can be found in the 'test_suite_scripts folder' at https://github.com/cta-wave/dpctf-deploy/tree/master. For additional details see also:

	https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md#part-i-installing-host-machine-required-software

If you encounter problems with an install using the interactive scripts or prefer to manually install the Test Suite, see:

	https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md#part-ii-build-and-run-the-test-suite

**Required Software**
- Windows 11
- WSL (Ubuntu 22.04 recommended)
- Git (in WSL)
- Docker Engine (WSL) — NOT Docker Desktop
- PowerShell (Admin)

## Quick Start Instructions

#### 1 — Get test_suite_scripts
**Note:** If `test_suite_scripts` is already present at `C:\Users\<your_username>\test_suite_scripts`, skip this step.

Open Ubuntu from the Start Menu:

	git clone https://github.com/cta-wave/dpctf-deploy.git ~/dpctf-temp
	cp -r ~/dpctf-temp/test_suite_scripts /mnt/c/Users/<your_username>/test_suite_scripts
	rm -rf ~/dpctf-temp
    
The test_suite_scripts folder will be copied to your computer at C:\Users\<your_username>\test_suite_scripts. The folder will contain all of the necessary scripts and instructions needed to install and run tests using the WAVE Test Suite.

#### 2 — Build the Test Suite (First Time Only)

Run:

	bash /mnt/c/Users/<your_username>/test_suite_scripts/build_wave_wsl.sh <your_username>

**Note:** If a previous `dpctf-deploy` folder exists, the build script backs it up automatically as `dpctf-deploy_<timestamp>`. Any recordings, results, and observation results from the prior build can be found in that backup folder under `test_recordings/`, `results/`, and `observation_results/`.

The script will prompt you for the following inputs during the build:

- **Branch** (default: master) — press Enter for the latest release, or enter `staging` for a pre-release build
- **Tag** (optional) — press Enter for latest on the selected branch, or enter a release tag (e.g. `v4.0.0`)
- **Build type**:
  - `1` = Full rebuild — fresh clone, clean start. Use for major version changes, corrupted state, or first-time builds. Backs up existing `dpctf-deploy` automatically.
  - `2` = Incremental update — updates the existing repo and skips unchanged content. Use for minor updates or when new tests or content have been added. Significantly faster than a full rebuild.
- **EULA agreement** — the script displays the EULA link and asks you to confirm. You must agree to continue. Declining exits the script.
- **Docker volume prune** (optional, full rebuild only) — removes unused Docker volumes system-wide. Press Enter to skip if unsure.

When the build completes you will see:

	BUILD COMPLETE

The EULA has been accepted and containers are running. Proceed to Step 3.

---

### 3 — Configure the Test Runner

Open **PowerShell as Administrator**:

	cd "C:\Users\<your_username>\test_suite_scripts"
	.\run_wave_admin.ps1

This script will:

- Display an EULA reminder at startup
- Prompt for:
  - 1-device or 2-device test
  - HTTP (host IP) or HTTPS (domain)
- Detect Host IP
- Configure networking and port forwarding
- Start Docker containers
- Configure Observation Framework (2-device only)
- Open a Notepad file with test instructions

### 4 — Run a Test

---
Follow the instructions shown in Notepad.

**Single Device Test**
- Host runs and displays the video

**Two Device Test:**

- Host controls test
- DUT plays video

For most 2-device tests, use HTTP / host IP.

---

### 5 — Record the Test

Record the DUT screen (or host screen for 1-device tests).

Save to:

	C:\Users\<your_username>\dpctf-deploy\test_recordings\

---
Supported formats:
- .mp4
- .mov

---

### 6 — Analyze the Recording

Open Ubuntu from the Start Menu:

	cd /mnt/c/Users/<your_username>/test_suite_scripts
	bash analyse_wave_recordings.sh

**Note:** The first time this script runs, it checks for the Device Observation Framework (DOF) Docker image. If not found, it will offer to build it automatically before proceeding. This only happens once.

---

## Daily Workflow

After initial build:

1. Run:

		run_wave_admin.ps1
    
2. Follow Notepad instructions  
3. Run test  
4. Record  
5. Analyze  

---

## Docker Management Commands

Stop containers:

	docker-compose down
    
Restart containers:

	docker-compose up -d

---

## Troubleshooting

Restart environment:

	cd /mnt/c/Users/<your_username>/dpctf-deploy
	docker-compose down
	docker-compose up -d
    
View logs:

	docker logs dpctf

If restarting containers doesn't fix the problem (e.g. containers won't start, or an image is missing/damaged), see "Full Docker Reset" in the WAVE_WSL_User_Guide.
