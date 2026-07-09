# Paylocity kiosk set up:



##### 1\. Shift + F10 during set up and run these commands:



* net user Kiosk Cursor-Fiber4-Polka /add
* net localgroup Administrators Kiosk /add

&#x09;

##### 2\. Open powershell as admin and run these commands:



* $Winlogon = "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon"
* Set-ItemProperty $Winlogon AutoAdminLogon -Value "1"
* Set-ItemProperty $Winlogon DefaultUserName -Value "Kiosk"
* Set-ItemProperty $Winlogon DefaultPassword -Value "Cursor-Fiber4-Polka"
* New-ItemProperty -Path $EdgeKey -Name "KioskSwipeGesturesEnabled" -Value 0 -PropertyType DWORD -Force
* New-ItemProperty -Path $WinKey -Name "AllowEdgeSwipe" -Value 0 -PropertyType DWORD -Force
* powercfg /change monitor-timeout-ac 0
* powercfg /change monitor-timeout-dc 0
* powercfg /change standby-timeout-ac 0
* powercfg /change standby-timeout-dc 0
* powercfg /change hibernate-timeout-ac 0
* powercfg /change hibernate-timeout-dc 0
* powercfg /requestsoverride PROCESS msedge.exe DISPLAY



* $Path1 = "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings"
* if (-not (Test-Path $Path1)) { New-Item -Path $Path1 -Force }
* Set-ItemProperty -Path $Path1 -Name "NOC\_GLOBAL\_SETTING\_TOASTS\_ENABLED" -Value 0 -Force
* Set-ItemProperty -Path $Path1 -Name "NOC\_GLOBAL\_SETTING\_DND" -Value 1 -Force
* $Path2 = "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications"
* if (-not (Test-Path $Path2)) { New-Item -Path $Path2 -Force }
* Set-ItemProperty -Path $Path2 -Name "ToastEnabled" -Value 0 -Force
* $Path3 = "HKCU:\\Software\\Policies\\Microsoft\\Windows\\Explorer"
* if (-not (Test-Path $Path3)) { New-Item -Path $Path3 -Force }
* Set-ItemProperty -Path $Path3 -Name "DisableNotificationCenter" -Value 1 -Force



##### 3\. Turn Brightness to max and turn off adaptive.



##### 4\. Move Logo.png and LogoScreensaver.scr to C:\\Windows\\System32\\



##### 5\. Window + R and go to gpedit.msc:



* User Configuration > Administrative Templates > Control Panel > Personalization

  * Turn on screen saver
  * Turn on timeout (60s)
  * Turn on force screen saver (C:\\Windows\\System32\\LogoScreenSaver.scr)



##### 6\. Open task scheduler:



* Create new task "Startup" that begins on login and runs kiosk_launcher.bat(ensure it runs on AND off battery)









