@echo off
:: Windows Configuration Script
:: This script runs once on first login and then deletes itself

title Windows 11 Configuration

echo ========================================
echo Windows 11 Custom Configuration
echo ========================================
echo.
echo Configuring your system...
echo.

:: Wait a few seconds for Windows to fully load
timeout /t 5 /nobreak >nul

:: Rename Admin account to User if it exists
echo [1/6] Configuring user accounts...
wmic useraccount where name='Admin' rename User 2>nul
net localgroup Administrators User /add 2>nul

:: Configure taskbar and start menu for all users
echo [2/6] Configuring taskbar and start menu...

:: Apply to current user
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul 2>&1

:: Apply to Default User profile (for future users)
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT" >nul 2>&1
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul 2>&1
reg unload "HKU\DefaultUser" >nul 2>&1

:: Install Chrome
echo [3/6] Installing Google Chrome...
powershell -ExecutionPolicy Bypass -Command "$chromeInstaller = '%TEMP%\ChromeSetup.exe'; try { Invoke-WebRequest -Uri 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile $chromeInstaller -UseBasicParsing; Start-Process -FilePath $chromeInstaller -ArgumentList '/silent', '/install' -Wait; Remove-Item $chromeInstaller -Force -ErrorAction SilentlyContinue; Write-Host 'Chrome installed successfully' } catch { Write-Host 'Chrome installation failed' }" 2>nul

:: Install Adobe Reader
echo [4/6] Installing Adobe Reader...
powershell -ExecutionPolicy Bypass -Command "$adobeInstaller = '%TEMP%\AdobeReaderSetup.exe'; try { Invoke-WebRequest -Uri 'https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300820555/AcroRdrDC2300820555_en_US.exe' -OutFile $adobeInstaller -UseBasicParsing; Start-Process -FilePath $adobeInstaller -ArgumentList '/sAll', '/rs', '/msi', 'EULA_ACCEPT=YES' -Wait; Remove-Item $adobeInstaller -Force -ErrorAction SilentlyContinue; Write-Host 'Adobe Reader installed successfully' } catch { Write-Host 'Adobe Reader installation failed' }" 2>nul

:: Install VLC
echo [5/6] Installing VLC Media Player...
powershell -ExecutionPolicy Bypass -Command "$vlcInstaller = '%TEMP%\vlc-installer.exe'; try { Invoke-WebRequest -Uri 'https://get.videolan.org/vlc/last/win64/vlc-3.0.21-win64.exe' -OutFile $vlcInstaller -UseBasicParsing; Start-Process -FilePath $vlcInstaller -ArgumentList '/L=1033', '/S' -Wait; Remove-Item $vlcInstaller -Force -ErrorAction SilentlyContinue; Write-Host 'VLC installed successfully' } catch { Write-Host 'VLC installation failed' }" 2>nul

:: Restart Explorer to apply changes
echo [6/6] Applying changes...
taskkill /F /IM explorer.exe >nul 2>&1
start explorer.exe

echo.
echo ========================================
echo Configuration Complete!
echo ========================================
echo.
echo Your system has been configured with:
echo - User account (Administrator)
echo - Start menu aligned to left
echo - Task View, Search, and Widgets hidden
echo - Chrome, Adobe Reader, and VLC installed
echo.
echo This window will close in 10 seconds...
timeout /t 10 /nobreak >nul

:: Remove RunOnce registry entry
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "ConfigureWindows" /f >nul 2>&1

:: Delete this script from startup folder and itself
del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\configure-windows.cmd" >nul 2>&1
(goto) 2>nul & del "%~f0"
