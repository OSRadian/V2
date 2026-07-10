@echo off
setlocal

set "GITURL=https://github.com/git-for-windows/git/releases/download/v2.55.0.windows.2/Git-2.55.0.2-64-bit.exe"
set "GITEXE=%TEMP%\GitSetup.exe"

echo Downloading Git...
curl.exe -L "%GITURL%" -o "%GITEXE%"

if errorlevel 1 (
    echo.
    echo ERROR: Failed to download Git.
    pause
    exit /b 1
)

if not exist "%GITEXE%" (
    echo.
    echo ERROR: Git installer was not downloaded.
    pause
    exit /b 1
)

echo Installing Git...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process -FilePath '%GITEXE%' -ArgumentList '/VERYSILENT /NORESTART' -Wait"

if errorlevel 1 (
    echo.
    echo ERROR: Git installation failed.
    pause
    exit /b 1
)

del "%GITEXE%"

echo.
echo Git has been installed successfully.
pause