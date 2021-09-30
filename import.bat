@echo off
setlocal enabledelayedexpansion


echo Downloading content ...
python download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/1197c7d793fefeeb2d3ecff2815c36f7e9e97581/database.json content
