@echo off

REM Update local V2 repository (force overwrite with GitHub version)
cd /d "C:\Users\Kiosk\Desktop\V2"
git fetch --all
git reset --hard origin/main
git clean -fd

echo 4 > "..\4.txt"

powershell -Command "Disable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"
taskkill /f /im ScreenClickTest.exe 2>nul
taskkill /f /im msedge.exe 2>nul
start "" "C:\Users\Kiosk\Desktop\V2\kiosk_script.exe"
start "" "msedge.exe" --kiosk "https://webtime2.paylocity.com/WebTime/Login/WebClock" --edge-kiosk-type=fullscreen
timeout /t 30 /nobreak
powershell -Command "Enable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"