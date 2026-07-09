@echo off
powershell -Command "Disable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"
taskkill /f /im ScreenClickTest.exe 2>nul
taskkill /f /im msedge.exe 2>nul
start "" "C:\Users\Kiosk\Desktop\kiosk_script.exe"
start "" "msedge.exe" --kiosk "https://webtime2.paylocity.com/WebTime/Login/WebClock" --edge-kiosk-type=fullscreen
timeout /t 30 /nobreak
powershell -Command "Enable-PnpDevice -InstanceId 'HID\ELAN9038&COL01\5&145F55AC&0&0000' -Confirm:$false"