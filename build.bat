@echo off
setlocal enabledelayedexpansion

set reload_runner=0
set reload_tests=0
set tests_branch="master"
set has_tests_branch=0
set test_runner_commit="v2.1.0"
set image_tag="v2.0.0"
set argument_count=0

for %%x in (%*) do (
    if %has_tests_branch%==1 (
        set tests_branch="%%~x"
        set has_tests_branch=0
    ) else (
        if not "%%~x:~0,2%%"=="--" (
            if %argument_count%==0 (
                set test_runner_commit="%%~x"
                set argument_count=1
            ) else if %argument_count%==1 (
                set image_tag="%%~x"
                set argument_count=2
            )
        )
    )
    if "%%~x"=="--reload-runner" set reload_runner=1
    if "%%~x"=="--reload-tests" set reload_tests=1
    if "%%~x"=="--tests-branch" set has_tests_branch=1
)

set args=

if %reload_runner%==1 set args=%args% --build-arg runner-rev=%DATE%
if %reload_tests%==1 set args=%args% --build-arg runner-rev=%DATE%

set command=docker build --network="host" --build-arg commit=%test_runner_commit%%args% --build-arg testsbranch=%tests_branch% -t dpctf:%image_tag% .

echo %command%

!command!
