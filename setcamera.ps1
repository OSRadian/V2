New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' `
    -Name 'LetAppsAccessCamera' `
    -Value 1 `
    -PropertyType DWord `
    -Force