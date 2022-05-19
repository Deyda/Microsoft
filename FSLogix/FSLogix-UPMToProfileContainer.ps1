<#
.SYNOPSIS
This script migrate from UPM to FSLogix Profile Container

.DESCRIPTION
Test before using!!

.NOTES
  Version:          1.99
  Author:           
  Rewrite Author:   Manuel Winkel <www.deyda.net>
  Creation Date:    2020-03-04
  Purpose/Change:
#>
#########################################################################################
# Setup Parameter first here newprofile oldprofile subfolder1 subfolder2
# Requires -RunAsAdministrator
# My Userprofiles come only with SAMAccount Name without Domain "\Username\2012R2\UPM_Profile
#########################################################################################
# Example from my UPM Path "\\path_to_your_share\username\2012R2\UPM_Profile"
# fslogix Root profile path
$newprofilepath = "E:\FSLogix"
# UPM Root profile path
$oldprofilepath = "D:\OLDPROFILE"
# Subfolder 1 - First Path to UPM_Profile Folder in UPM Profiles - see my example above
#$urigfolder = "d:\Folder2"
# Subfolder 2 - First Path to UPM_Profile Folder in UPM Profiles - see my example above
$subfolder2 = "UPM_Profile"

#########################################################################################
# Do not edit here
#########################################################################################
$oldprofiles = Get-ChildItem $oldprofilepath | Select-Object -Expand fullname | Sort-Object | out-gridview -OutputMode Multiple -title "Select profile(s) to convert"| ForEach-Object{
Join-Path $_ $subfolder2
}

foreach ($old in $oldprofiles) {
#$OldSplit = $old.split("\\")
$OldStrings = ([regex]::Matches($old, "\\" )).count
$OldSAM = $oldStrings - 1
$sam = $old.split("\\")[$OldSAM]
$sid = (New-Object System.Security.Principal.NTAccount($sam)).translate([System.Security.Principal.SecurityIdentifier]).Value
$regtext = "Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid]
`"ProfileImagePath`"=`"C:\\Users\\$sam`"
`"FSL_OriginalProfileImagePath`"=`"C:\\Users\\$sam`"
`"Flags`"=dword:00000000
`"State`"=dword:00000000
`"ProfileLoadTimeLow`"=dword:00000000
`"ProfileLoadTimeHigh`"=dword:00000000
`"RefCount`"=dword:00000000
`"RunLogonScriptSync`"=dword:00000000
"

$nfolder = join-path $newprofilepath ($sam)
if (!(test-path $nfolder)) {New-Item -Path $nfolder -ItemType directory | Out-Null}
& icacls $nfolder /setowner "$env:userdomain\$sam" /T /C
& icacls $nfolder /grant $env:userdomain\$sam`:`(OI`)`(CI`)F /T
$vhd = Join-Path $nfolder ("Profile_"+$sam+".vhdx")

$script1 = "create vdisk file=`"$vhd`" maximum 30720 type=expandable"
$script2 = "sel vdisk file=`"$vhd`"`r`nattach vdisk"
$script3 = "sel vdisk file=`"$vhd`"`r`ncreate part prim`r`nselect part 1`r`nformat fs=ntfs quick"
$script4 = "sel vdisk file=`"$vhd`"`r`nsel part 1`r`nassign letter=Y"
$script5 = "sel vdisk file`"$vhd`"`r`ndetach vdisk"
#$script6 = "sel vdisk file=`"$vhd`"`r`nattach vdisk readonly`"`r`ncompact vdisk"

if (!(test-path $vhd)) {
$script1 | diskpart
start-process icacls "$vhd /setowner $sam"
$script2 | diskpart
Start-Sleep -s 5
$script3 | diskpart
$script4 | diskpart
& label Y: Profile-$sam
New-Item -Path Y:\Profile -ItemType directory | Out-Null
Start-Sleep -s 5
start-process icacls "Y:\Profile /setowner SYSTEM"
Start-Process icacls -ArgumentList "Y:\Profile /inheritance:r"
$cmd1 = "Y:\Profile /grant $env:userdomain\$sam`:`(OI`)`(CI`)F"
Start-Process icacls -ArgumentList "Y:\Profile /grant SYSTEM`:`(OI`)`(CI`)F"
Start-Process icacls -ArgumentList "Y:\Profile /grant Administrators`:`(OI`)`(CI`)F"
Start-Process icacls -ArgumentList $cmd1
Start-Sleep -s 5
} else {

$script2 | diskpart
Start-Sleep -s 5
$script4 | diskpart
}
<#$urigpathper = $urigfolder + "\" + "$sam" + "\" + "AppData"
$urigpath = $urigfolder + "\" + "$sam" + "\" + "AppData" + "\*"#>
"Copying $old to $vhd"
Start-Sleep -s 5
& robocopy $old Y:\Profile /MIR /B /R:1 /W:1 /COPYALL | Out-Null
<#"Copying $urigpath to $vhd"
Start-Sleep -s 5
Copy-Item -Path "$urigpath" -Destination "Y:\Profile\AppData\Roaming" -Recurse -ErrorAction SilentlyContinue
$urigpathpermission = Get-Acl -Path $urigpathper
Set-Acl -AclObject $urigpathpermission -Path 'Y:\Profile\AppData\Roaming'
dir -r 'Y:\Profile\AppData\Roaming' | Set-Acl -AclObject $urigpathpermission

"Copying $urigpath2 to $vhd"
$urigpathper2 = $urigfolder + "\" + "$sam"
$urigpath2 = $urigfolder + "\" + "$sam" + "\*"
Start-Sleep -s 5
Copy-Item -Path "$urigpath2" -Destination "Y:\Profile" -Recurse -Exclude AppData -ErrorAction SilentlyContinue
$urigpathpermission2 = Get-Acl -Path $urigpathper2
Set-Acl -AclObject $urigpathpermission2 -Path 'Y:\Profile'
dir -r 'Y:\Profile' | Set-Acl -AclObject $urigpathpermission2#>


if (!(Test-Path "Y:\Profile\AppData\Local\FSLogix")) {
New-Item -Path "Y:\Profile\AppData\Local\FSLogix" -ItemType directory | Out-Null
}
if (!(Test-Path "Y:\Profile\AppData\Local\FSLogix\ProfileData.reg")) {$regtext | Out-File "Y:\Profile\AppData\Local\FSLogix\ProfileData.reg" -Encoding ascii}
$script5 | diskpart
}