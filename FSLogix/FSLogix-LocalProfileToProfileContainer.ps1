<#
.SYNOPSIS
This script migrate from Local Profile to FSLogix Profile Container

.DESCRIPTION
Test before using!!

.NOTES
  Version:          1.0
  Author:           
  Rewrite Author:   Manuel Winkel <www.deyda.net>
  Creation Date:    2020-03-04
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

#########################################################################################
# Do not edit here
#########################################################################################
$ENV:PATH=”$ENV:PATH;C:\Program Files\fslogix\apps\”
$oldprofiles = gci c:\users | ?{$_.psiscontainer -eq $true} | select -Expand fullname | sort | out-gridview -OutputMode Multiple -title "Select profile(s) to convert"

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

frx.exe copy-profile -filename $vhd -sid $sid
} 
