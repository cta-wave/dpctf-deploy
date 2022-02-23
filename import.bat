@echo off
setlocal enabledelayedexpansion


echo Downloading content ...
python download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/05c5987cf2ab218528c0e5bcde4d0a1cd09fb448/database.json content
