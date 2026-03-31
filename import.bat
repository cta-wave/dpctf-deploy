@echo off
setlocal enabledelayedexpansion

set CONTENT_VERSION=%~1
if "%CONTENT_VERSION%"=="" set CONTENT_VERSION=master
set CONTENT_URL=https://raw.githubusercontent.com/cta-wave/Test-Content/%CONTENT_VERSION%/database.json


::echo Downloading content ...
::python download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/75eecb6a5a558fddf8bbdd68c6a5b3675be55f0c/database.json content

echo ""
echo "DATA SIZE WARNING: This script will download a lot of data!"
echo ""

echo Downloading content from %CONTENT_VERSION% ...
docker run -it --rm --name import-content -v %cd%:/usr/src/import-content -w /usr/src/import-content python:3.8 python ./download-content.py %CONTENT_URL% content