@echo off
:: OOBE Setup Script - Downloads and places startup script
:: Run during OOBE: curl -L -o %TEMP%\oobe-setup.cmd https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/oobe-setup.cmd && %TEMP%\oobe-setup.cmd

echo Downloading startup configuration script...

:: Download the configuration script to All Users Startup folder
curl -L -o "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\configure-windows.cmd" https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/configure-windows.cmd

:: Also create a RunOnce registry entry as backup
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "ConfigureWindows" /t REG_SZ /d "cmd.exe /c \"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\configure-windows.cmd\"" /f

echo Setup script installed. It will run automatically on first login.
echo Press any key to close this window and continue with Windows setup...
pause >nul
