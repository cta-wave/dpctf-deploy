@echo off
setlocal enabledelayedexpansion


for /f "tokens=*" %%i in ('docker images -q dpctf-dof:v2.1.0 2^>nul') do set image=%%i
if not defined image (
    echo DOF image not found! Please build it using:
    echo .\build-dof.bat
    exit /b 1
)

if "%~1" == "" (
    echo No video recording provided!
    echo analyse-recordings.bat ^<video-file^>
    exit /b 1
)

set "absolute_path=%~f1"
set "dirname=%~dp1"
set "filename=%~nx1"

set "observation_ini=%~dp0observation-config.ini"
set "config_dir=%~dp0configuration"
set "args="

if exist "%observation_ini%" set "args=%args% -v "%observation_ini%":/usr/app/device-observation-framework/config.ini"
if exist "%config_dir%" set "args=%args% -v "%config_dir%":/usr/app/device-observation-framework/configuration"

set "start_args="
set count=0
for %%a in (%*) do (
    set /a count+=1
    if NOT !count! == 1 (
        set start_args=!start_args! %%a
    )
)

docker run -it --rm --network "host" -v %dirname%:/usr/app/recordings -v %~dp0observation_logs:/usr/app/device-observation-framework/logs -v %~dp0observation_results:/usr/app/device-observation-framework/results -e RECORDING_FILENAME=%filename% %args% dpctf-dof:v2.1.0 %start_args%
