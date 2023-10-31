@echo off
setlocal enabledelayedexpansion


echo Downloading content ...
python download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/75eecb6a5a558fddf8bbdd68c6a5b3675be55f0c/database.json content
