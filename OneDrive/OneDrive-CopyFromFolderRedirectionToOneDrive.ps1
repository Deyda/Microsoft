<#
.SYNOPSIS
The script copies the existing folders "desktop" and "documents" into the onedrive directory

.DESCRIPTION
Use this script to copy the Folder Redirection Folder Desktop and Documents local and fetch them into OneDrive Known Folder

.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-03-04
  Purpose/Change:
#>

$Documents = [environment]::getfolderpath("mydocuments")
$Desktop = [environment]::getfolderpath("desktop")
$Target = $env:OneDriveCommercial

    write-host 'OneDrive connected and found'
    robocopy $Documents $Target"/Documents" /E /SEC
    robocopy $Desktop $Target"/Desktop" /E /SEC
    new-item $Documents -name '_FILES COPIED TO ONEDRIVE.txt' -ItemType 'file' -Value 'Files Copied' -force
    new-item $Desktop -name '_FILES COPIED TO ONEDRIVE.txt' -ItemType 'file' -Value 'Files Copied' -force
