## WAVE Recording Analysis — Instructions

The WAVE Test Suite uses two components:

- **Test Runner (TR)** — runs the test and saves session results automatically to `dpctf-deploy/results/`
- **Device Observation Framework (DOF)** — analyzes the recorded video and posts results back to the Test Runner

---

### Prerequisites — before running the analysis script

- The test was run and completed on **this host machine** — analysis must be performed on the same host that ran the test
- The test session results are in `dpctf-deploy/results/` — these are saved automatically when the test completes
- The recording has been saved to:

		C:\Users\<your_username>\dpctf-deploy\test_recordings\

  Supported formats: `.mp4` `.mov`

---

### What the analysis script does

1. Checks for the DOF Docker image — builds it automatically on first run if not found (one time only)
2. Lists available recordings in `test_recordings/` for selection
3. Prompts for analysis options (see Options section below)
4. Backs up the original recording to `test_recordings_backups/`
5. Runs the analysis against the selected recording

---

### Output files

After analysis, the original recording is renamed with `_dpctf_<token>` appended and a `.wav` file is created alongside it.

Example:

	Original:  IMG_3824.mp4

	After:     IMG_3824_dpctf_b4c8b042-4210-11f0-9139-0242ac110002.mp4
	           IMG_3824_dpctf_b4c8b042-4210-11f0-9139-0242ac110002.wav

The token (`b4c8b042-4210-11f0-9139-0242ac110002`) is the full session token from the test run. The first 8 characters of the token identify the session in the Test Runner.

---

### Running the analysis script

To analyze a recording, open Ubuntu from the Start Menu and run:

	cd /mnt/c/Users/<your_username>/test_suite_scripts
	bash analyse_wave_recordings.sh

To analyze another recording, simply re-run the same command.

---

### Re-running analysis on the same recording

If you need to re-run analysis on a recording that has already been analyzed, you must select the full renamed file — not the original name. Example:

	IMG_3824_dpctf_b4c8b042-4210-11f0-9139-0242ac110002.mp4

The original file name no longer exists after the first analysis run. The script will list the renamed file in the recordings directory for selection.

---

### Analysis options

The script presents common options:

| Option | Flag | Description |
|---|---|---|
| 1 | none | Standard analysis |
| 2 | --log debug | Verbose logging for troubleshooting |
| 3 | --scan intensive | More thorough frame scanning |
| 4 | custom | Enter any valid option manually |

The script remembers your last-used file and options for convenience on subsequent runs.

For a full list of available options see:

	https://github.com/cta-wave/device-observation-framework/blob/v2.1.0/README.md#additional-options

---

### Viewing results

Analysis results are posted to the Test Runner session and saved locally in:

	dpctf-deploy/observation-results/

To view results in the Test Runner, open the session URL used during the test.

---

### Debugging

If the Observation Framework reports errors or that the device failed, see:

	https://github.com/cta-wave/device-observation-framework/wiki/Debugging-Observation-Failures

For general analysis reference see:

	https://github.com/cta-wave/dpctf-deploy?tab=readme-ov-file#running-the-analysis
