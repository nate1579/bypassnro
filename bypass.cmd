@echo off
  :: Windows 11 OOBE Bypass Script
  :: Creates admin user "User" with no password
  :: Configures taskbar and UI preferences

  :: Create local admin account
  net user User /add
  net localgroup Administrators User /add

  :: Disable network to bypass Microsoft account requirement
  netsh interface set interface "Wi-Fi" disabled 2>nul
  netsh interface set interface "Ethernet" disabled 2>nul

  :: Kill OOBE network flow
  taskkill /f /im oobenetworkconnectionflow.exe 2>nul

  :: Skip OOBE screens
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v PrivacyConsentStatus /t REG_DWORD /d 0 /f
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v SkipMachineOOBE /t REG_DWORD /d 1 /f
  reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v SkipUserOOBE /t REG_DWORD /d 1 /f

  :: Configure taskbar for new user profile (User)
  :: Taskbar alignment - left (0 = left, 1 = center)
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f

  :: Hide Search box
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f

  :: Hide Task View button
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0
   /f

  :: Hide Widgets button
  reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f

  :: Apply to default user profile so new accounts get these settings
  reg load "HKU\Default" "C:\Users\Default\NTUSER.DAT"
  reg add "HKU\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0
  /f
  reg add "HKU\Default\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0
  /f
  reg add "HKU\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t
  REG_DWORD /d 0 /f
  reg add "HKU\Default\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0
  /f
  reg unload "HKU\Default"

  echo Setup complete. Restarting OOBE...
  shutdown /r /t 3
