@echo off
REM CurlCopier Runner Script
REM
REM Usage: run.bat [APIKey]

chcp 65001 >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0examples\quickstart.ps1" %*
