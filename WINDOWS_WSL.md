# Setup on Windows using WSL2

## Requirements

- Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11 (untested)
  
## General Information:

### 1. Updating Windows paths

   There are a number of points in these instructions that will direct you to add the necessary path(s) to Windows System Variables under the PATH entry. You will need to add the Path(s) to the folder(s) that will contain the WAVE Test Suite files you will create, Python, Docker Desktop, ZBar and any others as noted in these instructions. This is so the system knows where to find them. There may be additional Paths necessary. When a command returns an error such as “file not found” check to see if the Path is in the Environment System Variables under “PATH”. If not, add the missing Path.  
   **To add to or modify the System Environment Variables**:
- Search for “Edit System Environmental Variables” in the search bar. Click on it in the popup.
- Select “Environment Variables”
- Under “System variables” (lower box), select “Path”
- Then select Edit
- Select “New” and enter the desired Path.
- Select “New” again for each new path you wish to add.
- When done, close the Environment Variables screens AND the Windows PowerShell/Terminal, if you have it open, to ensure the Paths are updated.
1. Follow the instructions in the various ReadMe files for **__Windows__, not Unix/Linux or Mac OS X**.
2. Run all commands using Windows Terminal/PowerShell. Do not run them using Bash in a Linux terminal.
3. If a command in Windows PowerShell/Terminal stalls or hangs up, use <Control + C> to gracefully exit.


### 2. These instructions are meant to augment the various [README] instructions 

https://github.com/cta-wave/dpctf-deploy/blob/master/README.md and https://github.com/cta-wave/device-observation-framework as well as others referred to in these [README] files for installation and use in a **Windows** WSL2 environment. The following instructions do not include many of the details that may be needed for more complex testing scenarios. They are included to assist in getting started.

## 1. Establish a compatible Windows/Linux/Docker environment

### 1.1 Download/install WSL2. 
Be sure to follow the installation instructions carefully.

1. Open “Windows PowerShell” by searching for Windows PowerShell in the search bar
   Right click on the “Windows Terminal/PowerShell” and select “Run as an Administrator”.  
   **Use PowerShell running as Administrator for all of the commands in these instructions.**
2. Enable WSL: Search for  “[**Windows Features**](https://www.tenforums.com/tutorials/7247-turn-windows-features-off-windows-10-a.html)” in the search bar and open “Turn Windows Features on of off”. Locate “**Windows Subsystem for Linux**”, and “**Virtual Machine**” select (check) both.
3. Restart the computer.
4. Set WSL2 as default by running the following command in PowerShell:  
   `wsl –set-default-version 2`

### 1.2 Verify LXSSMANAGER is running

This Service makes available a subsystem that deals with Linux executables (LX’s) called ELFs.

1. Press **WIN+R**
2. Type: **services.msc**
3. Find **LXSSMANAGER**
4. If it is not running: Right click it and select **RESTART**
5. (optional) Set auto-startup by right clicking it, select PROPERTIES and set startup type to **Automatic** if available.

### 1.3 Download/install a Linux distro

This guide will assume Ubuntu 20.04. Other distros should work but they have not been tested.

1. Follow the installation instructions, such as [these](https://windowsloop.com/install-linux-subsystem-windows-10/).

### 1.4 Download/install Docker Desktop

1. Download and install Docker Desktop from https://docs.docker.com/desktop/windows/wsl/ (it is not in Microsoft App Store)
2. Make certain WSL2 is checked under **Settings->General**
3. If it is not enabled, go to **Resources->Advanced->WSL Integration**
4. Check the WSL2 box and restart docker
5. Add the Path(s) to your Docker Desktop installation. See section on “**Updating Windows Paths**” at the top of these instructions.

## 2. Build the DPC test runner docker image

**NOTE**: The following is a brief description of the steps for a basic test setup. There are additional details in the [[ReadMe](https://github.com/cta-wave/dpctf-deploy/blob/master/README.md)] for more complex scenarios.

1. Clone the Test Runner from https://github.com/cta-wave/dpctf-deploy.git  
OR  
Download the dpctf-deploy files from github https://github.com/cta-wave/dpctf-deploy/archive/refs/heads/master.zip and extract them to the folder you will use for the WAVE Test Suite files. It will create a new folder, “**dpctf-deploy-master**” in the destination folder you extract it to.  
They are both available under the **Code** tab at https://github.com/cta-wave/dpctf-deploy
2. Add the Path to the new folder to the System Environment Variables PATH.
3. In **Windows PowerShell** change directory to the extracted files directory by typing **cd <Path to your new folder>**. For example: **cd d:\Docker_Files\dpctf-deploy-master**. **Note: Use the forward slash to separate directories and folders**.
4. Start **Docker Desktop** from the Start menu if it is not already running.
5. In the **Windows PowerShell** terminal type the command **./build.bat master latest**. Hit enter. This will take some time to complete. You should see the build’s progress proceeding.
6. When complete, type **docker-compose up -d** and hit enter to create the image. This will take some time to compete. You should see the build’s progress proceeding. When complete, you should see the Image “dpctf” was created in Docker.
7. Type ./import.bat to import the test content.
8. When complete, type docker-compose up and hit enter. This command will absorb the new container into your docker environment (it aggregates the output of this container with any other containers you have).
9. Verify the container was created in Docker by opening the Docker, left clicking on Containers/Apps and checking that the Container was created. It should show **dpctf-deploy-master** unless you changed the name. Then left click on Images to see that an image named **dpctf** was also created unless you changed the name.

### 3. Running the DPCTF Test Suite

To run the DPCTF Test Runner return to the [README](https://github.com/cta-wave/dpctf-deploy#readme). It goes all the way through to “Running tests”. There are several possible configurations (e.g. **Run on host machine**). Follow the appropriate section for your intended installation/Device under Test. Should you encounter difficulties, the [ReadMe] deals with debugging. The following NOTES include additional helpful notes and details.  

**NOTES:**

1. Recommended: Test the DPC Test Runner before installing the Observation Framework (see below) or capturing the video with a camera to confirm it is working. Follow the README instructions to run a test.
2. After entering http://localhost:8000/\_wave/index.html in a browser, configuring the test session, and starting the test, a new tab will open in the browser with the test video running and QR codes showing. __**This page must be showing on your screen when using Chrome or Edge for the test**__. If you wish to monitor the progress of the test using Chrome or Edge, move the initial “Set up” tab to a different monitor __immediately__ after starting the session. The original monitor should show the video running with QR codes. The progress and results will show on the setup tab you moved to the second monitor. Otherwise, just wait until playback ends to switch back to the Setup tab and view the results. On Firefox the playback screen does not need to be showing.
3. For the initial test, select only a couple of video files. The more files you select, the longer it will take to see the results. Also, make sure you select video encodings your PC/browser can play. E.g. if you can’t play 50 Hz video, don’t select those.
4. To run the Observation Framework you will need to capture the video playback on a suitable video camera (next section).

### 4. HELPFUL HINTS

1. If any of the commands entered in the Windows PowerShell/Terminal (build, import, etc.) appear to hang up/fail to complete (after making sure to let them run for some time. Some of the commands can take a fair amount of time to run depending on your machine and other variables and appear to stall. If you determine it has hung up you can gracefully exit by hitting **Ctrl + C** and then re-running the command. If it still fails you may need to delete the folder (dpctf-deploy-master or device-observation-framework depending on what you were doing at the time) and re-download the Zip file. Don’t forget to run docker-compose up -d after.
2. Use **docker stop <container_name>** e.g. **dpctf**, or **docker start <container_name>** in the Windows PowerShell to stop or start the docker container. This will gracefully stop/start the containers. You can see if it worked by looking at the Container in Docker Desptop. It will say “running” or “exited”.
3. **Important**: When you are done with your testing, run **docker stop dpctf**. A crash, Windows update, or other interruptions can cause the Docker to stop operating correctly requiring the container/images to be rebuilt by deleting the container first, followed by the image in the Docker Desktop and running **./build.bat master latest** and **docker-compose up -d** again. At least that has been my experience. You may also need to rerun **install_win.bat**.
4. When all else fails, delete the WAVE folders (dpctf-deploy-master and device-observation-framework folders), and uninstall Docker Desktop (after deleting the container and image) and reinstall it. Then follow the instructions for downloading and installing the Test Runner (**./build.bat master latest**) and the content (**./import.bat**), etc.
