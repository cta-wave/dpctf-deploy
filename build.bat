@echo off
setlocal enabledelayedexpansion

set reload_runner=0
set reload_tests=0
set tests_branch="master"
set has_tests_branch=0

for %%x in (%*) do (
   if %has_tests_branch%==1 set tests_branch="%%~x"
   if "%%~x"=="--reload-runner" set reload_runner=1
   if "%%~x"=="--reload-tests" set reload_tests=1
   if "%%~x"=="--tests-branch" set has_tests_branch=1
)

set args=

if %reload_runner%==1 set args=%args% --build-arg runner-rev=%DATE%
if %reload_tests%==1 set args=%args% --build-arg runner-rev=%DATE%

set command=docker build --network="host" --build-arg commit=%1%args% --build-arg testsbranch=%tests_branch% -t dpctf:%2 .

echo %command%

!command!
