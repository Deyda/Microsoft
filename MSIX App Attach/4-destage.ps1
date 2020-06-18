<#
.SYNOPSIS
The script unmount the VHD/X File
.DESCRIPTION
Use this script to unmount a MSIX App Attach Container
.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-06-04
  Purpose/Change:
#>
#region variables 
$packageName = "<package name>" 
$vhdSrc="<path to vhd>"

$msixJunction = "C:\temp\AppAttach\" 
#endregion

#region derregister
Remove-AppxPackage -AllUsers -Package $packageName

cd $msixJunction 
rmdir $packageName -Recurse -Force -Confirm:$false
#endregion

#Dismount VHD
disMount-Diskimage -ImagePath $vhdSrc
