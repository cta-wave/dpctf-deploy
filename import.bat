@echo off
setlocal enabledelayedexpansion


echo Downloading content ...
python download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/master/database.json content