@echo off
setlocal enabledelayedexpansion


::echo Downloading content ...
::python download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/75eecb6a5a558fddf8bbdd68c6a5b3675be55f0c/database.json content

docker run -it --rm --name import-content -v %cd%:/usr/src/import-content -w /usr/src/import-content python:3.8 sh ./download-content.sh