<#
.SYNOPSIS
The script register the MSIX package in user context
.DESCRIPTION
Use this script to register the MSIX App Attach Container in the user context
.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-06-04
  Purpose/Change:
#>
#region variables 
$packageName = "<package name>" 

$path = "C:\Program Files\WindowsApps\" + $packageName + "\AppxManifest.xml"
#endregion

#region register
Add-AppxPackage -Path $path -DisableDevelopmentMode -Register
#endregion 
