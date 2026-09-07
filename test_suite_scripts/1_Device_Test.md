### Run a Single Device Test

**Selected mode:** <selected_mode>

**Note:** Before proceeding, and for additional details on how to record and run a test, read Phase 2 of the CTA WAVE README:  
https://github.com/cta-wave/dpctf-deploy?tab=readme-ov-file#phase-2-test-execution-and-recording-to-be-performed-by-tester

**Note:** At the end of the day it is good practice to run `docker-compose down` to stop all containers. If the Host PC restarts unexpectedly, Docker containers can sometimes be damaged. Restart the containers using `docker-compose up -d`.

**Recommendation:** After a build or rebuild, it is simplest to run your first verification test as a 1-device test using the host IP over HTTP. HTTPS/domain mode is also supported if name resolution and certificate trust are already configured correctly.

---

### Before starting, ensure:

- The build completed successfully and the EULA was accepted
- `run_wave_admin.ps1` completed successfully — it displays an EULA reminder at startup; if the Test Runner URL does not load, verify EULA was accepted during the build
- The selected Test Runner URL opens successfully in a browser:  
  <test_runner_index_url>

### Rerun `run_wave_admin.ps1` if needed:

- after a reboot
- after switching Ethernet/Wi-Fi
- if the host IP changed
- if the WSL IP changed

Otherwise, for another test on the same setup, just restart the stack if needed.

**Note:** If an existing `observation-config.ini` file is present, `run_wave_admin.ps1` leaves it unchanged. That file is not required for 1-device testing.

---

### Single Device (1-device) Test

In a 1-device test, the Host and DUT are the same device.

**1. Open a browser on the host PC and enter:**

  <test_runner_index_url>

**2. Confirm that the browser shows the Test Runner landing page.**

**3. Select the test or tests you want to run using _Configure Session_.**

**Note:** When running the first test after building the Test Suite, select only one or two validated tests to confirm the setup is working correctly.

**4. Select _Start Session_ at the bottom of the configuration screen.**

A new browser tab will open showing the test is running.

**5. Immediately switch to the new tab and start recording.**

You only have a few seconds after starting the session to begin recording.

- Do not move the mouse across the screen once the video starts to play.

**6. Stop the recording when the _Session completed_ screen is visible.**

**7. Save the recording in a suitable location and save the session token for later use during analysis.**

---

### Troubleshooting

If the test does not start, appears to stall, or does not complete normally:

**a.** Retry the test from step 1.

**b.** Restart the containers. In PowerShell as Administrator, run:

`docker-compose down`  
`docker-compose up -d`

**c.** After restarting the containers, rerun the test from step 1.

**d.** Try running the test using a different browser, for example Chrome, Firefox, or Edge.

**e.** For additional troubleshooting assistance, or to build the test suite manually from scratch, see:

https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md

and

https://github.com/cta-wave/dpctf-deploy?tab=readme-ov-file#getting-started-with-wave-streaming-media-test-suite---devices

---

### Analyze the recording

After saving the recording, open Ubuntu from the Start Menu and run:

	cd /mnt/c/Users/<your_username>/test_suite_scripts
	bash analyse_wave_recordings.sh

The script will:
- List available recordings in `test_recordings/` for selection
- Prompt for analysis options
- Back up the original recording automatically
- Run the analysis and open detailed instructions in Notepad

**Note:** The first time this script runs, it checks for the Device Observation Framework (DOF) Docker image. If not found, it will offer to build it automatically before proceeding. This only happens once.



