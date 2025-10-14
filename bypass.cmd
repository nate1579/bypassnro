@echo off
echo Setting up Windows 11 configuration...

:: Download startup configuration script
curl -L -o "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\configure-windows.cmd" https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/configure-windows.cmd

:: Create RunOnce registry entry as backup
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "ConfigureWindows" /t REG_SZ /d "cmd.exe /c \"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\configure-windows.cmd\"" /f

:: Download unattend.xml and run sysprep to bypass OOBE
curl -L -o C:\Windows\Panther\unattend.xml https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/unattend.xml
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
