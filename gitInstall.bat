@echo off
set "TEMPFILE=%TEMP%\GitSetup.exe"

echo Downloading Git...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe' -OutFile '%TEMPFILE%'"

echo Installing Git...
"%TEMPFILE%" /VERYSILENT /NORESTART

del "%TEMPFILE%"

echo.
echo Git installation complete.
pause