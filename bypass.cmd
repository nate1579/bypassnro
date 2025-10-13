copy /Y "%~dp0unattend.xml" "C:\Windows\Panther\unattend.xml"
%WINDIR%\System32\Sysprep\Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
