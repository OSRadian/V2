@echo off

powershell -Command "Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name ScreenSaveTimeOut -Value '60'"

powershell -Command "powercfg /requestsoverride PROCESS msedge.exe DISPLAY"
powershell -Command "$b = Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue; if($b){$b.WmiSetBrightness(1,90)}"

powershell -Command "New-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop' -Name ScreenSaveTimeOut -Value '60' -PropertyType String -Force"

powershell -Command "Disable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"
taskkill /f /im ScreenClickTest.exe 2>nul
taskkill /f /im msedge.exe 2>nul

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

start "" "msedge.exe" --kiosk "https://webtime2.paylocity.com/WebTime/Login/WebClock" --edge-kiosk-type=fullscreen

:WaitForWindow
tasklist /V /FI "IMAGENAME eq msedge.exe" | find /I "WebClock" >nul
if errorlevel 1 (
    timeout /t 1 /nobreak >nul
    goto WaitForWindow
)

start "" "%USERPROFILE%\Desktop\V2\kiosk_script.exe"

timeout /t 45 /nobreak
powershell -Command "Enable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"