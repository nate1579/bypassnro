@echo off
:: OOBE Bypass and Configuration Script
:: Run during OOBE: curl -L -o %TEMP%\oobe-bypass.cmd https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/oobe-bypass.cmd && %TEMP%\oobe-bypass.cmd

echo Starting Windows 11 OOBE bypass and configuration...

:: Kill OOBE to skip setup
taskkill /F /IM oobenet workfoldertaskkill /F /IM msoobe.exe 2>nul

:: Create User account as Administrator
net user User "" /add /passwordreq:no /active:yes
net localgroup Administrators User /add

:: Remove Admin account if exists
net user Admin /delete 2>nul

:: Configure taskbar and start menu settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f

:: Apply to Default User profile
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f
reg unload "HKU\DefaultUser"

:: Download and run application installer script
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/install-apps.ps1 | iex"

echo Configuration complete. Restarting in 10 seconds...
timeout /t 10
shutdown /r /t 0
