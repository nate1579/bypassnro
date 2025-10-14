@echo off
echo Setting up Windows 11 configuration...

:: Create setup scripts directory if it doesn't exist
if not exist "C:\Windows\Setup\Scripts" mkdir "C:\Windows\Setup\Scripts"

:: Download configuration script to persistent location
curl -L -o "C:\Windows\Setup\Scripts\configure-windows.cmd" https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/configure-windows.cmd

:: Create RunOnce registry entry to run on first login
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "ConfigureWindows" /t REG_SZ /d "cmd.exe /c \"C:\Windows\Setup\Scripts\configure-windows.cmd\"" /f

:: Download unattend.xml and run sysprep to bypass OOBE
curl -L -o C:\Windows\Panther\unattend.xml https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/unattend.xml
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
