@echo off

cd /d "%USERPROFILE%\Desktop\V2"

git restore -- kiosk_script.exe

powershell -Command "$b = Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue; if($b){$b.WmiSetBrightness(1,90)}"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\Desktop\V2\Register-KioskWakeTask.ps1"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$cd = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; New-Item -Path $cd -Force | Out-Null; New-ItemProperty -Path $cd -Name 'DisableWindowsConsumerFeatures' -PropertyType DWord -Value 1 -Force | Out-Null; $sys = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; New-Item -Path $sys -Force | Out-Null; New-ItemProperty -Path $sys -Name 'EnableFirstLogonAnimation' -PropertyType DWord -Value 0 -Force | Out-Null"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; $au = Join-Path $wu 'AU'; New-Item -Path $wu -Force | Out-Null; New-Item -Path $au -Force | Out-Null; New-ItemProperty -Path $wu -Name 'UpdateNotificationLevel' -PropertyType DWord -Value 2 -Force | Out-Null; New-ItemProperty -Path $wu -Name 'SetActiveHours' -PropertyType DWord -Value 1 -Force | Out-Null; New-ItemProperty -Path $wu -Name 'ActiveHoursStart' -PropertyType DWord -Value 5 -Force | Out-Null; New-ItemProperty -Path $wu -Name 'ActiveHoursEnd' -PropertyType DWord -Value 23 -Force | Out-Null; New-ItemProperty -Path $au -Name 'AUOptions' -PropertyType DWord -Value 4 -Force | Out-Null; New-ItemProperty -Path $au -Name 'ScheduledInstallTime' -PropertyType DWord -Value 3 -Force | Out-Null"

powershell -Command "Disable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"
taskkill /f /im ScreenClickTest.exe 2>nul
taskkill /f /im msedge.exe 2>nul

:WaitForEdgeExit
tasklist /FI "IMAGENAME eq msedge.exe" | find /I "msedge.exe" >nul
if not errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto WaitForEdgeExit
)

REM Find kiosk number
set "KIOSKNUM="

for %%F in ("%USERPROFILE%\Desktop\?.txt") do (
    if "%%~nF" GEQ "1" if "%%~nF" LEQ "7" (
        set "KIOSKNUM=%%~nF"
        goto :FoundKiosk
    )
)

:FoundKiosk
if defined KIOSKNUM (
    powershell -Command ^
        "(Get-Content '%USERPROFILE%\Desktop\V2\config.ini') -replace '^Kiosk=.*','Kiosk=Kiosk%KIOSKNUM%' | Set-Content '%USERPROFILE%\Desktop\V2\config.ini'"
)

timeout /t 15 /nobreak

set /a LaunchAttempts=0

:LaunchEdge
set /a LaunchAttempts+=1
set /a WaitSeconds=0

echo Starting Edge (Attempt %LaunchAttempts%)...

start "" "msedge.exe" --kiosk "https://webtime2.paylocity.com/WebTime/Login/WebClock" --edge-kiosk-type=fullscreen

:WaitForWindow
tasklist /V /FI "IMAGENAME eq msedge.exe" | find /I "WebClock" >nul
if not errorlevel 1 goto EdgeReady

timeout /t 1 /nobreak >nul
set /a WaitSeconds+=1

if %WaitSeconds% GEQ 60 (
    echo Edge did not load within 60 seconds. Restarting...

    taskkill /f /im msedge.exe >nul 2>&1

    :WaitForRestartExit
    tasklist /FI "IMAGENAME eq msedge.exe" | find /I "msedge.exe" >nul
    if not errorlevel 1 (
        timeout /t 1 /nobreak >nul
        goto WaitForRestartExit
    )

    if %LaunchAttempts% GEQ 3 (
        echo Failed to launch Edge after 3 attempts.
        exit /b 1
    )

    goto LaunchEdge
)

goto WaitForWindow

:EdgeReady

start "" "%USERPROFILE%\Desktop\V2\kiosk_script.exe"

timeout /t 45 /nobreak
powershell -Command "Enable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"