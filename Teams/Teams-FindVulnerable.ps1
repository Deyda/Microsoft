# https://www.theregister.com/2020/12/07/microsoft_teams_rce_flaw/
# https://github.com/oskarsve/ms-teams-rce
# Taking the vulnerable version from the above repo. I'm hoping that's the latest version this flaw exists on
# Output format is for limitations in our MSP software
# username:version (shows what version user is running, for every user running Teams at time of scan)
# RunMin = Lowest version found running
# RunMax = Highest version found running
# InstalledVersions = What versions are registered in add/remove programs
# and if the installed version is vulnerable, but user versions have updated, let us know situation is actually OK

$vulnerable = New-Object System.Version 1.3.00.21759
$script:runningMax = New-Object System.Version 0.0.0.0
$script:runningMin = New-Object System.Version 10.0.0.0

Function comp ($v) {
    if ($v -gt $script:runningMax) { $script:runningMax = $v}
    if ($v -lt $script:runningMin) { $script:runningMin = $v}
}

$isVulnerable = $false
$BadVersions = @()
$Procs = Get-WmiObject Win32_Process -Filter "name='teams.exe'" | Select ProcessID, Name, @{Name="UserName";Expression={$_.GetOwner().Domain+"\"+$_.GetOwner().User}} 
# this test shouldn't be needed, but PS2 is screwing it up...
if ($null -ne $procs) {
    ForEach ($Proc in $procs) {
        $process = Get-Process -id $proc.processid
        $v = New-Object System.Version $process.productversion
        comp $v
        if ($v -le $vulnerable) {
            $isVulnerable = $true
            $BadVersions += "$($Proc.UserName):$($Process.ProductVersion)"
        }
    }
    $BadVersions = @($BadVersions | Sort -Unique)
    $BadVersions += "RunMin $($script:runningMin) RunMax $($script:runningMax)"
    if ($script:runningMin -le $vulnerable) {
        $BadVersions += "Running vulnerable version"
    } else {
        $BadVersions += "Oldest running is OK tho"
    }
}

$SW = @(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ea SilentlyContinue | Where-Object { $_.DisplayName -match 'Teams' -and $_.Publisher -match 'Microsoft Corporation' -and $_.SystemComponent -ne 0x1 -and $_.ParentDisplayName -eq $null } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString)
$SW += @(Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ea SilentlyContinue | Where-Object { $_.DisplayName -match 'Teams' -and $_.Publisher -match 'Microsoft Corporation' -and $_.SystemComponent -ne 0x1 -and $_.ParentDisplayName -eq $null } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, HelpLink, UninstallString)
ForEach ($TeamsInstallation in $SW) {
    # just in case somehow >1 here
    $InstalledVersion = New-Object System.Version $TeamsInstallation.DisplayVersion
    if ($InstalledVersion -le $vulnerable) {
        $isVulnerable = $true
        $BadVersions += "InstalledVuln $($InstalledVersion)"
    }
}
if ($isVulnerable) {
    $BadVersions -join ","
}
