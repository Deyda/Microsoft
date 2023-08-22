<#
.SYNOPSIS
The script sets all files in OneDrive path to Cloud Only

.DESCRIPTION
Use this script to free space on your local system

.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2023-08-22
  Purpose/Change:
#>


get-childitem $ENV:OneDriveCommercial -Force -File -Recurse -ErrorAction SilentlyContinue |
Where-Object {$_.Attributes -match 'ReparsePoint' -or $_.Attributes -eq '525344' } |
ForEach-Object {
    attrib.exe $_.fullname +U -P /s
}
