<#
.SYNOPSIS
This script migrate from UPM to FSLogix Profile Container

.DESCRIPTION
Test before using!!

.NOTES
  Version:          1.99 (modified)
  Author:
  Rewrite Author:   Manuel Winkel <www.deyda.net>
  Purpose/Change:   Added exclude folders + auto free drive letter selection
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

# Subfolder 2 - Path to UPM_Profile folder inside each user folder
$subfolder2 = "UPM_Profile"

# Preferred temp drive letter for mounted VHD (use if free, otherwise auto-pick)
$PreferredVHDDriveLetter = "Y"

# Exclude folders (relative to profile root)
$ExcludeDirs = @(
  "AppData\Local\Packages\MSTeams_8wekyb3d8bbwe",
  "AppData\Local\Microsoft\Teams",
  "AppData\Roaming\Microsoft\Teams",
  "AppData\Local\Publishers\8wekyb3d8bbwe"
)

#########################################################################################
# Helper: pick a free drive letter
#########################################################################################
function Get-FreeDriveLetter {
    param(
        [ValidatePattern('^[A-Z]$')]
        [string]$Preferred = "Y"
    )

    $used = @()

    # Local volumes
    try {
        $used += (Get-Volume -ErrorAction Stop | Where-Object DriveLetter | Select-Object -ExpandProperty DriveLetter)
    } catch {}

    # PSDrives (includes mapped drives)
    try {
        $used += (Get-PSDrive -PSProvider FileSystem | ForEach-Object { $_.Name })
    } catch {}

    $used = $used | ForEach-Object { $_.ToUpper() } | Sort-Object -Unique

    $pref = $Preferred.ToUpper()
    if ($used -notcontains $pref) { return $pref }

    foreach ($l in ([char[]]([char]'Z'..[char]'D'))) { # skip A,B,C
        $letter = $l.ToString()
        if ($used -notcontains $letter) { return $letter }
    }

    throw "Kein freier Laufwerksbuchstabe gefunden (D..Z sind belegt)."
}

#########################################################################################
# Do not edit here (logic)
#########################################################################################

$oldprofiles = Get-ChildItem $oldprofilepath |
    Select-Object -Expand fullname |
    Sort-Object |
    Out-GridView -OutputMode Multiple -Title "Select profile(s) to convert" |
    ForEach-Object { Join-Path $_ $subfolder2 }

foreach ($old in $oldprofiles) {

    # Determine SAM from path
    $OldStrings = ([regex]::Matches($old, "\\" )).count
    $OldSAM = $OldStrings - 1
    $sam = $old.split("\\")[$OldSAM]

    # Resolve SID
    $sid = (New-Object System.Security.Principal.NTAccount($sam)).Translate([System.Security.Principal.SecurityIdentifier]).Value

    # FSLogix ProfileData.reg content
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

    # Create destination folder
    $nfolder = Join-Path $newprofilepath ("$sam" + "_" + "$sid")
    if (!(Test-Path $nfolder)) { New-Item -Path $nfolder -ItemType Directory | Out-Null }

    & icacls $nfolder /setowner "$env:userdomain\$sam" /T /C | Out-Null
    & icacls $nfolder /grant "$env:userdomain\$sam`:(OI)(CI)F" /T | Out-Null

    $vhd = Join-Path $nfolder ("Profile_" + $sam + ".vhdx")

    # Pick a free drive letter for THIS iteration
    $VHDDriveLetter = Get-FreeDriveLetter -Preferred $PreferredVHDDriveLetter
    $MountRoot = "$($VHDDriveLetter):\"
    $ProfileRoot = Join-Path $MountRoot "Profile"

    # Diskpart scripts
    $script1 = "create vdisk file=`"$vhd`" maximum 30720 type=expandable"
    $script2 = "sel vdisk file=`"$vhd`"`r`nattach vdisk"
    $script3 = "sel vdisk file=`"$vhd`"`r`ncreate part prim`r`nselect part 1`r`nformat fs=ntfs quick"
    $script4 = "sel vdisk file=`"$vhd`"`r`nsel part 1`r`nassign letter=$VHDDriveLetter"
    $script5 = "sel vdisk file=`"$vhd`"`r`ndetach vdisk"

    if (!(Test-Path $vhd)) {

        $script1 | diskpart | Out-Null

        # Set owner for VHD file
        Start-Process icacls -ArgumentList "`"$vhd`" /setowner $sam" -Wait -WindowStyle Hidden

        # Attach + format + assign letter
        $script2 | diskpart | Out-Null
        Start-Sleep -Seconds 5
        $script3 | diskpart | Out-Null
        $script4 | diskpart | Out-Null

        & label "$($VHDDriveLetter):" "Profile-$sam" | Out-Null
        New-Item -Path $ProfileRoot -ItemType Directory -Force | Out-Null
        Start-Sleep -Seconds 2

        # ACLs in mounted profile
        Start-Process icacls -ArgumentList "`"$ProfileRoot`" /setowner SYSTEM" -Wait -WindowStyle Hidden
        Start-Process icacls -ArgumentList "`"$ProfileRoot`" /inheritance:r" -Wait -WindowStyle Hidden
        Start-Process icacls -ArgumentList "`"$ProfileRoot`" /grant SYSTEM`:(OI)(CI)F" -Wait -WindowStyle Hidden
        Start-Process icacls -ArgumentList "`"$ProfileRoot`" /grant Administrators`:(OI)(CI)F" -Wait -WindowStyle Hidden
        Start-Process icacls -ArgumentList "`"$ProfileRoot`" /grant $env:userdomain\$sam`:(OI)(CI)F" -Wait -WindowStyle Hidden

        Start-Sleep -Seconds 2

    } else {

        # Attach + assign letter (no re-format)
        $script2 | diskpart | Out-Null
        Start-Sleep -Seconds 5
        $script4 | diskpart | Out-Null
        Start-Sleep -Seconds 2
    }

    "Copying $old to $vhd (Drive $($VHDDriveLetter):), excluding Teams/Publishers caches..."
    Start-Sleep -Seconds 2

    # Copy profile with excludes
    & robocopy $old $ProfileRoot /MIR /B /R:1 /W:1 /COPYALL /XD $ExcludeDirs | Out-Null

    # Remove Windows Search Folder (repair per-user search)
    $SearchPath = Join-Path $ProfileRoot "AppData\Roaming\Microsoft\Search"
    if (Test-Path $SearchPath) {
        Remove-Item -Path $SearchPath -Force -Recurse | Out-Null
    }

    # Ensure FSLogix folder + ProfileData.reg
    $FslPath = Join-Path $ProfileRoot "AppData\Local\FSLogix"
    if (!(Test-Path $FslPath)) {
        New-Item -Path $FslPath -ItemType Directory -Force | Out-Null
    }

    $ProfileDataReg = Join-Path $FslPath "ProfileData.reg"
    if (!(Test-Path $ProfileDataReg)) {
        $regtext | Out-File $ProfileDataReg -Encoding ascii
    }

    # Detach VHD
    $script5 | diskpart | Out-Null
}
