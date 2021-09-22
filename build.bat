@echo off
setlocal enabledelayedexpansion

set reload_runner=0
set reload_tests=0

for %%x in (%*) do (
   if "%%~x"=="--reload-runner" set reload_runner=1
   if "%%~x"=="--reload-tests" set reload_tests=1
)

set args=

if %reload_runner%==1 set args=%args% --build-arg runner-rev=%DATE%
if %reload_tests%==1 set args=%args% --build-arg runner-rev=%DATE%

set command=docker build --build-arg commit=%1%args% -t dpctf:%2 .

echo %command%

!command!