# Register-KioskWakeTask.ps1 — creates the hourly KioskWake scheduled task
# Run elevated, from the kiosk user's session.
 
$TaskName   = 'KioskWake'
$ScriptPath = "$env:USERPROFILE\Desktop\V2\Refresh\runWake.bat"
$RunAsUser  = "$env:USERDOMAIN\$env:USERNAME"
 
if (-not (Test-Path $ScriptPath)) {
    throw "Script not found at $ScriptPath"
}
 
# Remove any previous version of the task
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
 
$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""
 
# Fire at the top of the next hour, then every hour indefinitely
$startTime = (Get-Date).Date.AddHours((Get-Date).Hour + 1)
$trigger = New-ScheduledTaskTrigger -Once -At $startTime `
    -RepetitionInterval (New-TimeSpan -Minutes 5)
 
# Interactive is required — the task must reach the desktop to inject input
$principal = New-ScheduledTaskPrincipal -UserId $RunAsUser `
    -LogonType Interactive -RunLevel Limited
 
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
 
Register-ScheduledTask -TaskName $TaskName `
    -Action $action -Trigger $trigger -Principal $principal -Settings $settings `
    -Description 'Wakes the kiosk from the screensaver and refreshes the browser page.' | Out-Null
 
Write-Host "Task '$TaskName' created. First run: $startTime"