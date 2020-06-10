#Go and package your app using the MSIX App packager
#region variables

$vhdSrc="<path to vhd>"
$packageName = "<package name>" 
$parentFolder = "<package parent folder>"
$msixmgrPath = "<path to msixmgr.exe>"
$msixPath = "<path to msix file>"

$parentFolder = "\" + $parentFolder
$parts = $packageName.split("_")
$volumeName = "MSIX-" + $parts[0]
$packagePath = $msixPath + $packageName + ".msix"
#endregion

#Generate a VHD or VHDX package for MSIX
new-vhd -sizebytes 1024MB -path $vhdSrc -dynamic -confirm:$false
$vhdObject = Mount-VHD $vhdSrc -Passthru
$disk = Initialize-Disk -Passthru -Number $vhdObject.Number
$partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $disk.Number
Format-Volume -FileSystem NTFS -Confirm:$false -DriveLetter $partition.DriveLetter -Force
$Path = $partition.DriveLetter + ":" + $parentFolder

#Create a folder with Package Parent Folder Variable as the name of the folder in root drive mounted above
new-item -path $Path -ItemType Directory
Set-Volume -DriveLetter $partition.DriveLetter -NewFileSystemLabel $volumeName


#Expand MSIX in CMD in Admin cmd prompt - Get the full package name
cd $msixmgrPath
.\msixmgr.exe -Unpack -packagePath $packagePath -destination $Path -applyacls
