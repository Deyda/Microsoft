<#
.SYNOPSIS
This script migrate from  FSLogix Profile Container to FSLogix Profile Container

.DESCRIPTION
Test before using!!

.NOTES
  Version:          1.0
  Author:           
  Rewrite Author:   Manuel Winkel <www.deyda.net>
  Creation Date:    2023-08-21
  Purpose/Change:
  NOTE: This only works between like profile versions. eg. You can’t migrate your 2008R2 profiles to Server 2016 and expect it to work.
        This requires using frx.exe, which means that FSLogix needs to be installed on the server that contains the profiles. The script will create the folders in the USERNAME_SID format, and set all proper permissions.
        Use this script. Edit it. Run it (as administrator) from the Citrix server. It will pop up this screen to select what profiles to migrate.
#>

#########################################################################################
# Setup Parameter first here newprofilepath
# Requires -RunAsAdministrator
# Requires FSLogix Agent (frx.exe)
#########################################################################################
# Example "\\domain.com\share\path"
# fslogix Root profile path
$newprofilepath = "\\domain.com\share\path"
$oldprofilepath = "\\domain.com\share\path"
#########################################################################################
# Do not edit here
#########################################################################################
$ENV:PATH=”$ENV:PATH;C:\Program Files\fslogix\apps\”
$oldprofiles = gci $oldprofilepath | ?{$_.psiscontainer -eq $true} | select -Expand fullname | sort | out-gridview -OutputMode Multiple -title "Select profile(s) to convert"

# foreach old profile
foreach ($old in $oldprofiles) {

$sam = ($old | split-path -leaf)
$sid = (New-Object System.Security.Principal.NTAccount($sam)).translate([System.Security.Principal.SecurityIdentifier]).Value

# set the nfolder path to \\newprofilepath\username_sid
$nfolder = join-path $newprofilepath ($sam+"_"+$sid)
# if $nfolder doesn't exist - create it with permissions
if (!(test-path $nfolder)) {New-Item -Path $nfolder -ItemType directory | Out-Null}
& icacls $nfolder /setowner "$env:userdomain\$sam" /T /C
& icacls $nfolder /grant $env:userdomain\$sam`:`(OI`)`(CI`)F /T

# sets vhd to \\nfolderpath\profile_username.vhdx (you can make vhd or vhdx here)
$vhd = Join-Path $nfolder ("Profile_"+$sam+".vhdx")
$oldvhd = Join-Path $old ("Profile_"+$sam+".vhdx")

$script1 = "create vdisk file=`"$vhd`" maximum 30720 type=expandable"
$script2 = "sel vdisk file=`"$vhd`"`r`nattach vdisk"
$script3 = "sel vdisk file=`"$vhd`"`r`ncreate part prim`r`nselect part 2`r`nformat fs=ntfs quick"
$script4 = "sel vdisk file=`"$vhd`"`r`nsel part 2`r`nassign letter=Y"
$script5 = "sel vdisk file`"$vhd`"`r`ndetach vdisk"
$script6 = "sel vdisk file=`"$oldvhd`"`r`nattach vdisk"
$script7 = "sel vdisk file=`"$oldvhd`"`r`nsel part 1`r`nassign letter=z"
$script8 = "sel vdisk file`"$oldvhd`"`r`ndetach vdisk"
$script9 = "sel vdisk file=`"$vhd`"`r`nconvert GPT"

if (!(test-path $vhd)) {
$script1 | diskpart
start-process icacls "$vhd /setowner $sam"
$script2 | diskpart
$script9 | diskpart
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
"Copying $old to $vhd"
$script6 | diskpart
$script7 | diskpart
Start-Sleep -s 5
& robocopy Z:\Profile Y:\Profile /MIR /B /R:1 /W:1 /COPYALL | Out-Null
Start-Sleep -s 5
$script5 | diskpart
$script8 | diskpart
}
