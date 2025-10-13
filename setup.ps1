# Windows 11 OOBE Custom Setup Script
# Run this during OOBE: powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/nate1579/bypassnro/refs/heads/main/setup.ps1 | iex"

Write-Host "Starting Windows 11 customization..." -ForegroundColor Green

# Remove Admin account if it exists, ensure User account exists as Administrator
Write-Host "Configuring user accounts..." -ForegroundColor Yellow
try {
    $adminExists = Get-LocalUser -Name "Admin" -ErrorAction SilentlyContinue
    if ($adminExists) {
        Remove-LocalUser -Name "Admin" -ErrorAction Stop
        Write-Host "Removed Admin account" -ForegroundColor Green
    }
} catch {
    Write-Host "Could not remove Admin account: $_" -ForegroundColor Red
}

try {
    $userExists = Get-LocalUser -Name "User" -ErrorAction SilentlyContinue
    if (-not $userExists) {
        New-LocalUser -Name "User" -NoPassword -AccountNeverExpires -ErrorAction Stop
        Write-Host "Created User account" -ForegroundColor Green
    }
    Add-LocalGroupMember -Group "Administrators" -Member "User" -ErrorAction SilentlyContinue
    Write-Host "User account is now an Administrator" -ForegroundColor Green
} catch {
    Write-Host "User account configuration: $_" -ForegroundColor Yellow
}

# Taskbar and Start Menu Configuration
Write-Host "Configuring taskbar and start menu..." -ForegroundColor Yellow

# Set Start Menu to Left (TaskbarAl = 0)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord -Force

# Hide Task View Button
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force

# Hide Search Box
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force

# Disable Widgets
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force

# Apply to Default User profile
Write-Host "Applying settings to default user profile..." -ForegroundColor Yellow
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f
reg unload "HKU\DefaultUser"

Write-Host "Taskbar configured successfully" -ForegroundColor Green

# Install Applications
Write-Host "Installing Chrome..." -ForegroundColor Yellow
try {
    $chromeInstaller = "$env:TEMP\ChromeSetup.exe"
    Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromeInstaller -UseBasicParsing
    Start-Process -FilePath $chromeInstaller -ArgumentList "/silent", "/install" -Wait
    Remove-Item $chromeInstaller -Force -ErrorAction SilentlyContinue
    Write-Host "Chrome installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Chrome installation failed: $_" -ForegroundColor Red
}

Write-Host "Installing Adobe Reader..." -ForegroundColor Yellow
try {
    $adobeInstaller = "$env:TEMP\AdobeReaderSetup.exe"
    Invoke-WebRequest -Uri "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300820555/AcroRdrDC2300820555_en_US.exe" -OutFile $adobeInstaller -UseBasicParsing
    Start-Process -FilePath $adobeInstaller -ArgumentList "/sAll", "/rs", "/msi", "EULA_ACCEPT=YES" -Wait
    Remove-Item $adobeInstaller -Force -ErrorAction SilentlyContinue
    Write-Host "Adobe Reader installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Adobe Reader installation failed: $_" -ForegroundColor Red
}

Write-Host "Installing VLC..." -ForegroundColor Yellow
try {
    $vlcInstaller = "$env:TEMP\vlc-installer.exe"
    Invoke-WebRequest -Uri "https://get.videolan.org/vlc/last/win64/vlc-3.0.21-win64.exe" -OutFile $vlcInstaller -UseBasicParsing
    Start-Process -FilePath $vlcInstaller -ArgumentList "/L=1033", "/S" -Wait
    Remove-Item $vlcInstaller -Force -ErrorAction SilentlyContinue
    Write-Host "VLC installed successfully" -ForegroundColor Green
} catch {
    Write-Host "VLC installation failed: $_" -ForegroundColor Red
}

# Restart Explorer to apply changes
Write-Host "Restarting Explorer to apply changes..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 2

Write-Host "Windows 11 customization completed!" -ForegroundColor Green
Write-Host "Please restart your computer for all changes to take effect." -ForegroundColor Cyan
