# Application Installer Script
Write-Host "Installing applications..." -ForegroundColor Green

# Install Chrome
Write-Host "Installing Chrome..." -ForegroundColor Yellow
try {
    $chromeInstaller = "$env:TEMP\ChromeSetup.exe"
    Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromeInstaller -UseBasicParsing
    Start-Process -FilePath $chromeInstaller -ArgumentList "/silent", "/install" -Wait
    Remove-Item $chromeInstaller -Force -ErrorAction SilentlyContinue
    Write-Host "Chrome installed" -ForegroundColor Green
} catch {
    Write-Host "Chrome install failed: $_" -ForegroundColor Red
}

# Install Adobe Reader
Write-Host "Installing Adobe Reader..." -ForegroundColor Yellow
try {
    $adobeInstaller = "$env:TEMP\AdobeReaderSetup.exe"
    Invoke-WebRequest -Uri "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2300820555/AcroRdrDC2300820555_en_US.exe" -OutFile $adobeInstaller -UseBasicParsing
    Start-Process -FilePath $adobeInstaller -ArgumentList "/sAll", "/rs", "/msi", "EULA_ACCEPT=YES" -Wait
    Remove-Item $adobeInstaller -Force -ErrorAction SilentlyContinue
    Write-Host "Adobe Reader installed" -ForegroundColor Green
} catch {
    Write-Host "Adobe Reader install failed: $_" -ForegroundColor Red
}

# Install VLC
Write-Host "Installing VLC..." -ForegroundColor Yellow
try {
    $vlcInstaller = "$env:TEMP\vlc-installer.exe"
    Invoke-WebRequest -Uri "https://get.videolan.org/vlc/last/win64/vlc-3.0.21-win64.exe" -OutFile $vlcInstaller -UseBasicParsing
    Start-Process -FilePath $vlcInstaller -ArgumentList "/L=1033", "/S" -Wait
    Remove-Item $vlcInstaller -Force -ErrorAction SilentlyContinue
    Write-Host "VLC installed" -ForegroundColor Green
} catch {
    Write-Host "VLC install failed: $_" -ForegroundColor Red
}

Write-Host "Application installation complete!" -ForegroundColor Green
