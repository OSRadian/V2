@echo off

REM Update local V2 repository (force overwrite with GitHub version)
cd /d "%USERPROFILE%\Desktop\V2"
git fetch --all
git reset --hard origin/main
git clean -fd

powershell -Command ^
"$b = Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue; if($b){$b.WmiSetBrightness(1,100)}"

powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO ADAPTBRIGHTNESS 0
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO ADAPTBRIGHTNESS 0

powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEODIM 0
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEODIM 0

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

start "" "%USERPROFILE%\Desktop\V2\kiosk_script.exe"
start "" "msedge.exe" --kiosk "https://webtime2.paylocity.com/WebTime/Login/WebClock" --edge-kiosk-type=fullscreen
timeout /t 30 /nobreak
powershell -Command "Enable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"