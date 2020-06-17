<#
.SYNOPSIS
The script deregister the MSIX Package
.DESCRIPTION
Use this script to deregister the MSIX Package
.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-06-04
  Purpose/Change:
#>
#region variables 
$packageName = "<package name>" 
#endregion

#region derregister
Remove-AppxPackage -PreserveRoamableApplicationData $packageName 
#endregion 
