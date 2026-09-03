# KioskWake.ps1 — dismiss the screensaver and reset the idle timer
 
# 1. Kill any running screensaver process (.scr)
$savers = Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -like '*.scr' }
 
foreach ($s in $savers) {
    try {
        Stop-Process -Id $s.Id -Force -ErrorAction Stop
        Write-Output "Killed $($s.ProcessName) (PID $($s.Id))"
    } catch {
        Write-Output "Could not kill $($s.ProcessName): $($_.Exception.Message)"
    }
}
 
if (-not $savers) { Write-Output "No screensaver process running" }
 
# 2. Reset the last-input timer so it doesn't immediately relaunch
Start-Sleep -Milliseconds 250
$shell = New-Object -ComObject WScript.Shell
$shell.SendKeys('{SCROLLLOCK}')
Start-Sleep -Milliseconds 100
$shell.SendKeys('{SCROLLLOCK}')

# 3. Focus the Edge window and refresh
Start-Sleep -Seconds 3
 
$edge = Get-Process msedge -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 } |
    Select-Object -First 1
 
if ($edge) {
    $shell.AppActivate($edge.Id) | Out-Null
    Start-Sleep -Milliseconds 250
    $shell.SendKeys('{F5}')
    Start-Sleep -Milliseconds 300
    $shell.SendKeys('{ENTER}')
} else {
    Write-Output "No Edge window found"
}