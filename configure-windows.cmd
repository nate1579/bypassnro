@echo off
setlocal enabledelayedexpansion

:: Check for admin privileges and self-elevate if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo ========================================
echo Windows Post-Setup Configuration Script
echo ========================================
echo.

:: ============================================
:: SYSTEM CONFIGURATION
:: ============================================

echo [1/8] Configuring system settings...

:: Allow upgrades with unsupported TPM or CPU
reg add "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Chat auto-install
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v ConfigureChatAutoInstall /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable News and Interests
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul 2>&1

:: Set password to never expire
net accounts /maxpwage:UNLIMITED >nul 2>&1

:: Disable Sticky Keys system-wide
reg add "HKU\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 10 /f >nul 2>&1

echo Done.
echo.

:: ============================================
:: REMOVE BLOATWARE APPS
:: ============================================

echo [2/8] Removing bloatware apps (this may take several minutes)...

:: Remove provisioned packages
powershell -NoProfile -Command "$packages = @('Microsoft.Microsoft3DViewer','Microsoft.BingSearch','Clipchamp.Clipchamp','Microsoft.Copilot','Microsoft.549981C3F5F10','Microsoft.Windows.DevHome','MicrosoftCorporationII.MicrosoftFamily','Microsoft.WindowsFeedbackHub','Microsoft.Edge.GameAssist','Microsoft.GetHelp','Microsoft.Getstarted','microsoft.windowscommunicationsapps','Microsoft.WindowsMaps','Microsoft.MixedReality.Portal','Microsoft.BingNews','Microsoft.MicrosoftOfficeHub','Microsoft.Office.OneNote','Microsoft.OutlookForWindows','Microsoft.Paint','Microsoft.MSPaint','Microsoft.People','Microsoft.Windows.Photos','Microsoft.PowerAutomateDesktop','MicrosoftCorporationII.QuickAssist','Microsoft.SkypeApp','Microsoft.MicrosoftSolitaireCollection','Microsoft.MicrosoftStickyNotes','MicrosoftTeams','MSTeams','Microsoft.Todos','Microsoft.Wallet','Microsoft.Xbox.TCUI','Microsoft.XboxApp','Microsoft.XboxGameOverlay','Microsoft.XboxGamingOverlay','Microsoft.XboxIdentityProvider','Microsoft.XboxSpeechToTextOverlay','Microsoft.GamingApp','Microsoft.YourPhone','Microsoft.ZuneVideo'); foreach($pkg in $packages){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $pkg} | Remove-AppxProvisionedPackage -AllUsers -Online -ErrorAction SilentlyContinue}" >nul 2>&1

:: Remove user-installed packages
powershell -NoProfile -Command "$packages = @('Microsoft.Microsoft3DViewer','Microsoft.BingSearch','Clipchamp.Clipchamp','Microsoft.Copilot','Microsoft.549981C3F5F10','Microsoft.Windows.DevHome','MicrosoftCorporationII.MicrosoftFamily','Microsoft.WindowsFeedbackHub','Microsoft.Edge.GameAssist','Microsoft.GetHelp','Microsoft.Getstarted','microsoft.windowscommunicationsapps','Microsoft.WindowsMaps','Microsoft.MixedReality.Portal','Microsoft.BingNews','Microsoft.MicrosoftOfficeHub','Microsoft.Office.OneNote','Microsoft.OutlookForWindows','Microsoft.Paint','Microsoft.MSPaint','Microsoft.People','Microsoft.Windows.Photos','Microsoft.PowerAutomateDesktop','MicrosoftCorporationII.QuickAssist','Microsoft.SkypeApp','Microsoft.MicrosoftSolitaireCollection','Microsoft.MicrosoftStickyNotes','MicrosoftTeams','MSTeams','Microsoft.Todos','Microsoft.Wallet','Microsoft.Xbox.TCUI','Microsoft.XboxApp','Microsoft.XboxGameOverlay','Microsoft.XboxGamingOverlay','Microsoft.XboxIdentityProvider','Microsoft.XboxSpeechToTextOverlay','Microsoft.GamingApp','Microsoft.YourPhone','Microsoft.ZuneVideo'); foreach($pkg in $packages){Get-AppxPackage -Name $pkg | Remove-AppxPackage -ErrorAction SilentlyContinue}" >nul 2>&1

echo Done.
echo.

:: ============================================
:: REMOVE CAPABILITIES
:: ============================================

echo [3/8] Removing Windows capabilities...

powershell -NoProfile -Command "$caps = @('Language.Handwriting~~~','Browser.InternetExplorer~~~','MathRecognizer~~~','OneCoreUAP.OneSync~~~','OpenSSH.Client~~~','Microsoft.Windows.MSPaint~~~','Microsoft.Windows.PowerShell.ISE~~~','App.Support.QuickAssist~~~','Language.Speech~~~','Language.TextToSpeech~~~','App.StepsRecorder~~~','Hello.Face.18967~~~','Hello.Face.Migration.18967~~~','Hello.Face.20134~~~','Media.WindowsMediaPlayer~~~'); foreach($cap in $caps){Get-WindowsCapability -Online | Where-Object {$_.Name -like \"*$cap*\" -and $_.State -ne 'NotPresent'} | Remove-WindowsCapability -Online -ErrorAction SilentlyContinue}" >nul 2>&1

echo Done.
echo.

:: ============================================
:: REMOVE FEATURES
:: ============================================

echo [4/8] Removing Windows features...

powershell -NoProfile -Command "Disable-WindowsOptionalFeature -Online -FeatureName 'MediaPlayback' -Remove -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Disable-WindowsOptionalFeature -Online -FeatureName 'MicrosoftWindowsPowerShellV2Root' -Remove -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Disable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-RemoteDesktopConnection' -Remove -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Disable-WindowsOptionalFeature -Online -FeatureName 'Recall' -Remove -NoRestart -ErrorAction SilentlyContinue" >nul 2>&1

echo Done.
echo.

:: ============================================
:: ONEDRIVE REMOVAL
:: ============================================

echo [5/8] Removing OneDrive...

:: Remove scheduled tasks
schtdel /Query | findstr /C:"DevHomeUpdate" >nul 2>&1 && schtasks /Delete /TN "DevHomeUpdate" /F >nul 2>&1
schtdel /Query | findstr /C:"OutlookUpdate" >nul 2>&1 && schtasks /Delete /TN "OutlookUpdate" /F >nul 2>&1

:: Remove OneDrive files
del /F /Q "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" >nul 2>&1
del /F /Q "C:\Windows\System32\OneDriveSetup.exe" >nul 2>&1
del /F /Q "C:\Windows\SysWOW64\OneDriveSetup.exe" >nul 2>&1

echo Done.
echo.

:: ============================================
:: CURRENT USER CONFIGURATION
:: ============================================

echo [6/8] Configuring current user settings...

:: Disable Copilot
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul 2>&1
powershell -NoProfile -Command "Get-AppxPackage -Name 'Microsoft.Windows.Ai.Copilot.Provider' | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1

:: Enable classic context menu
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f >nul 2>&1

:: Launch to This PC
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v LaunchTo /t REG_DWORD /d 1 /f >nul 2>&1

:: Hide search box
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >nul 2>&1

:: Show file extensions
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul 2>&1

:: Hide Task View button
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 2>&1

:: Left-align taskbar (Windows 11)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable End Task in taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Bing search results
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable Game DVR
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul 2>&1

:: Remove OneDrive from startup
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f >nul 2>&1

:: Disable Sticky Keys for current user
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 10 /f >nul 2>&1

:: NumLock on by default
reg add "HKU\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f >nul 2>&1

:: Configure desktop icons - ClassicStartMenu
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{5399e694-6ce5-4d6c-8fce-1d8870fdcba0}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{b4bfcc3a-db2c-424c-b029-7fe99a87c641}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{a8cdff1c-4878-43be-b5fd-f8091c1c60d0}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{374de290-123f-4565-9164-39c4925e467b}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{1cf1260c-4dd0-4ebb-811f-33c572699fde}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{3add1653-eb32-4cb0-bbd7-dfa0abb5acca}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{645ff040-5081-101b-9f08-00aa002f954e}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{20d04fe0-3aea-1069-a2d8-08002b30309d}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{a0953c92-50dc-43bf-be83-3742fed03c9c}" /t REG_DWORD /d 0 /f >nul 2>&1

:: Configure desktop icons - NewStartPanel
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{5399e694-6ce5-4d6c-8fce-1d8870fdcba0}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{b4bfcc3a-db2c-424c-b029-7fe99a87c641}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{a8cdff1c-4878-43be-b5fd-f8091c1c60d0}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{374de290-123f-4565-9164-39c4925e467b}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{1cf1260c-4dd0-4ebb-811f-33c572699fde}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{f02c1a0d-be21-4350-88b0-7367fc96ef3c}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{3add1653-eb32-4cb0-bbd7-dfa0abb5acca}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645ff040-5081-101b-9f08-00aa002f954e}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20d04fe0-3aea-1069-a2d8-08002b30309d}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{a0953c92-50dc-43bf-be83-3742fed03c9c}" /t REG_DWORD /d 0 /f >nul 2>&1

:: Configure Start menu folders
powershell -NoProfile -Command "Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Start' -Name 'VisiblePlaces' -Value ([convert]::FromBase64String('ztU0LVr6Q0WC8iLm6vd3PC+zZ+PeiVVDv85h83sYqTe8JIoUDNaJQqCAbtm7okiCIAYLsFF/MkyqHjTMVH9zFUSBdf4NCK5Ci9o07Ze2Y5RKsL10SvloT4vWQ5gHHai8oAc/OArogEywWobbhF28TYYIc1KqUUNCn3sndlhGWdTFpbNChn30QoCkk/rKeoi1')) -Type 'Binary' -ErrorAction SilentlyContinue" >nul 2>&1

:: Empty Start menu pins (Windows 11)
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v ConfigureStartPins /t REG_SZ /d "{\"pinnedList\":[]}" /f >nul 2>&1

echo Done.
echo.

:: ============================================
:: DEFAULT USER CONFIGURATION
:: ============================================

echo [7/8] Configuring default user profile...

:: Load default user registry hive
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT" >nul 2>&1

if %errorlevel% equ 0 (
    :: Disable Copilot
    reg add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul 2>&1

    :: Audio policy config
    reg add "HKU\DefaultUser\Software\Microsoft\Internet Explorer\LowRegistry\Audio\PolicyConfig\PropertyStore" /f >nul 2>&1

    :: Remove OneDrive from startup
    reg delete "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f >nul 2>&1

    :: Disable Game DVR
    reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul 2>&1

    :: Show file extensions
    reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul 2>&1

    :: Hide Task View button
    reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f >nul 2>&1

    :: Left-align taskbar
    reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f >nul 2>&1

    :: NumLock on by default
    reg add "HKU\DefaultUser\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f >nul 2>&1

    :: Disable Bing search results
    reg add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f >nul 2>&1

    :: Enable End Task in taskbar
    reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /t REG_DWORD /d 1 /f >nul 2>&1

    :: Disable Sticky Keys
    reg add "HKU\DefaultUser\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 10 /f >nul 2>&1

    :: Unload default user registry hive
    reg unload "HKU\DefaultUser" >nul 2>&1

    echo Done.
) else (
    echo Warning: Could not load default user hive. Some settings may not apply to new users.
)

echo.

:: ============================================
:: INSTALL APPLICATIONS
:: ============================================

echo [8/8] Installing applications with winget...

:: Check if winget is available
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: winget is not available. Skipping application installation.
    echo You can install apps manually or update Windows to get winget.
    goto :skipwinget
)

echo Installing Google Chrome...
winget install -e --id Google.Chrome --silent --accept-source-agreements --accept-package-agreements

echo Installing Mozilla Firefox...
winget install -e --id Mozilla.Firefox --silent --accept-source-agreements --accept-package-agreements

echo Installing VLC Media Player...
winget install -e --id VideoLAN.VLC --silent --accept-source-agreements --accept-package-agreements

echo Installing Adobe Acrobat Reader...
winget install -e --id Adobe.Acrobat.Reader.64-bit --silent --accept-source-agreements --accept-package-agreements

echo Done.

:skipwinget

echo.

:: ============================================
:: PIN APPS TO TASKBAR
:: ============================================

echo [9/9] Pinning apps to taskbar...

:: Pin File Explorer to taskbar
powershell -NoProfile -Command "$shell = New-Object -ComObject shell.application; $shell.NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Self.InvokeVerb('taskbarpin')" 2>nul

:: Wait for Chrome installation to complete and pin it
timeout /t 3 /nobreak >nul
powershell -NoProfile -Command "$chromePath = 'C:\Program Files\Google\Chrome\Application\chrome.exe'; if (Test-Path $chromePath) { $shell = New-Object -ComObject shell.application; $folder = $shell.Namespace((Split-Path $chromePath)); $item = $folder.ParseName((Split-Path $chromePath -Leaf)); $item.InvokeVerb('taskbarpin') }" 2>nul

:: Alternative method for Windows 11 - Create pinned items via registry
powershell -NoProfile -Command "if ([System.Environment]::OSVersion.Version.Build -ge 22000) { $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'; if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }; $pins = @('C:\Windows\explorer.exe', 'C:\Program Files\Google\Chrome\Application\chrome.exe'); foreach ($pin in $pins) { if (Test-Path $pin) { $shortcut = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar', [System.IO.Path]::GetFileNameWithoutExtension($pin) + '.lnk'); $WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut($shortcut); $Shortcut.TargetPath = $pin; $Shortcut.Save() } } }" 2>nul

echo Done.
echo.

echo.
echo ========================================
echo Configuration complete!
echo ========================================
echo.
echo The following changes have been made:
echo - Removed bloatware apps and packages
echo - Removed unnecessary Windows capabilities and features
echo - Disabled Copilot, Cortana, and OneDrive
echo - Enabled classic context menu
echo - Configured taskbar (left-aligned, search hidden, end task enabled)
echo - Configured File Explorer (show extensions, launch to This PC)
echo - Enabled NumLock by default
echo - Disabled Sticky Keys
echo - Configured desktop icons
echo - Disabled Bing search results
echo - Installed Chrome, Firefox, VLC, and Adobe Reader
echo - Pinned Chrome and File Explorer to taskbar
echo.
echo A system restart is recommended to apply all changes.
echo.

choice /C YN /M "Do you want to restart now"
if errorlevel 2 goto :end
if errorlevel 1 shutdown /r /t 10 /c "Restarting to apply configuration changes..."

:end
pause
