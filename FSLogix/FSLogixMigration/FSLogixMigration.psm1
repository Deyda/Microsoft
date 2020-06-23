. "$PSScriptRoot\Main Functions\Convert-RoamingProfile.ps1"
. "$PSScriptRoot\Main Functions\Convert-UPDProfile.ps1"
. "$PSScriptRoot\Main Functions\Convert-UPMProfile.ps1"
. "$PSScriptRoot\Helper Functions\Copy-Profile.ps1"
. "$PSScriptRoot\Helper Functions\Get-ProfileSource.ps1"
. "$PSScriptRoot\Helper Functions\Mount-UPDProfile.ps1"
. "$PSScriptRoot\Helper Functions\New-MigrationObject.ps1"
. "$PSScriptRoot\Helper Functions\New-ProfileDisk.ps1"
. "$PSScriptRoot\Helper Functions\New-ProfileReg.ps1"
. "$PSScriptRoot\Helper Functions\Write-Log.ps1"

Write-Host "
+---------------------------------------------------------+
+               FSLogix Migration Module                  +
+-------------------------------------------------------- +
+   Convert Roaming/UPD Profiles to FSLogix profile       +
+   containers.                                           +
+                                                         +
+   To get started type Get-Help Convert-RoamingProfile   +
+   or Get-Help Convert-UPDProfile                        +
+                                                         +
+ Version: 1.0                                            +
+---------------------------------------------------------+
"

if (!(Get-Command Get-ADUser)){
    Write-Warning "ActiveDirectory Module not found on this machine. This tool is required to migrate profiles."
}
if (!(Get-Command New-VHD)){
    Write-Warning "Hyper-V Module not found on this machine. This tool is required to create VHDs."
}
if (!(Get-Module -ListAvailable Pester | Where-Object Version -GE 4.8.1)){
    Write-Warning "Pester Module version 4.8.1 or higher was not found on this machine. This tool is required to run Pester Tests."
}