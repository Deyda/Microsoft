#MSIX app attach de staging sample
#region variables 
$packageName = "<package name>" 
$vhdSrc="<path to vhd>"

$msixJunction = "C:\temp\AppAttach\" 
#endregion

#region derregister
Remove-AppxPackage -AllUsers -Package $packageName

cd $msixJunction 
rmdir $packageName -Force -Verbose 
#endregion

#Dismount VHD
disMount-Diskimage -ImagePath $vhdSrc
