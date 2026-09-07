## Run a Two Device Test

**Selected mode:** <selected_mode>

**Note:** Before proceeding, and for additional details on how to record and run a test, read Phase 2 of the CTA WAVE README:  
https://github.com/cta-wave/dpctf-deploy?tab=readme-ov-file#phase-2-test-execution-and-recording-to-be-performed-by-tester

**Note:** At the end of the day it is good practice to run `docker-compose down` to stop all containers. If the Host PC restarts unexpectedly, Docker containers can sometimes be damaged. Restart the containers using `docker-compose up -d`.

**Recommendation:** After a build or rebuild, it is simplest to run your first verification test as a 1-device test using the host IP over HTTP before moving to 2-device testing.

---

### Before starting, ensure:

- The build completed successfully and the EULA was accepted
- `run_wave_admin.ps1` completed successfully — it displays an EULA reminder at startup; if the Test Runner URL does not load, verify EULA was accepted during the build
- The Host and DUT are on the same network
- The DUT can reach the selected Test Runner URL:  
  <test_runner_index_url>

### Rerun `run_wave_admin.ps1` if needed:

- after a reboot
- after switching Ethernet/Wi-Fi
- if the host IP changed
- if the WSL IP changed

Otherwise, for another test on the same setup, just restart the stack if needed.

---

### HTTP vs HTTPS for 2-device tests

For most 2-device tests, use **HTTP / host IP**.

Use **HTTPS / domain** only if **both** the Host and DUT are configured with:

- a hosts or DNS entry mapping the selected domain to the current Host IP
- the trusted root CA certificate used to create the HTTPS certificate
- working access to the HTTPS Test Runner URL

If either device is not configured for HTTPS correctly, select **HTTP / host IP** when running `run_wave_admin.ps1`.

**Selected Test Runner address:**  
  <test_runner_base_url>

---

### Observation Framework configuration

For 2-device testing, `run_wave_admin.ps1` creates `observation-config.ini` if it does not already exist.

If `observation-config.ini` already exists, `run_wave_admin.ps1` preserves user customizations and updates only:

  test_runner_url = <dof_test_runner_url>

Current file path:

  <observation_config_path>

---

## Two Device (2-device) Test

**1. On the DUT, open a browser and enter:**

  <test_runner_index_url>

**2. Wait for the DUT token to appear.**

**3. On the Host PC, open a browser and enter:**

  <test_runner_config_url>

**4. Enter the first 8 characters of the DUT token in the Host browser.**

**5. Configure the session on the Host.**

**Note:** When running the first test after building the Test Suite, select only one or two validated tests to confirm the setup is working correctly.

**6. Select _Start Session_ on the Host.**

**7. Immediately start recording the DUT screen.**

You only have a few seconds after starting the session before the video begins.

**8. Stop the recording when the _Session completed_ screen is visible on the DUT.**

**9. Save the recording, then copy or move it to:**

  C:\Users\<your_username>\dpctf-deploy\test_recordings\

**10. Save the session token for later use during analysis.**

---

### HTTPS/domain note for 2-device testing

If you selected HTTPS/domain mode, make sure the DUT also has:

- a hosts or DNS entry for <domain>
- the trusted root CA certificate installed
- browser access to <test_runner_index_url> before starting the session

---

## Troubleshooting

If the DUT does not start the test, appears to stall, or fails to complete normally:

**a.** Allow it to continue until the results page or completed status appears. Do not manually end the test.

**b.** Retry the test.

**c.** Try a different browser such as Chrome, Firefox, or Edge.

**d.** Restart the containers. In PowerShell as Administrator, run:

	docker-compose down
	docker-compose up -d

**e.** After restarting the containers, rerun the test from step 1.

**f.** For additional troubleshooting help, or to build the Test Suite manually from scratch, see:

	https://github.com/cta-wave/dpctf-deploy/blob/master/Final_Instructions_WSL2_20241220.md

and

	https://github.com/cta-wave/dpctf-deploy?tab=readme-ov-file#getting-started-with-wave-streaming-media-test-suite---devices


## Analyze the recording

After saving the recording, open Ubuntu from the Start Menu and run:

	cd /mnt/c/Users/<your_username>/test_suite_scripts
	bash analyse_wave_recordings.sh

The script will:
- List available recordings in `test_recordings/` for selection
- Prompt for analysis options
- Back up the original recording automatically
- Run the analysis and open detailed instructions in Notepad

**Note:** The first time this script runs, it checks for the Device Observation Framework (DOF) Docker image. If not found, it will offer to build it automatically before proceeding. This only happens once.



