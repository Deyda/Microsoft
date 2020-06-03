<#
.SYNOPSIS
This script migrate from Profile Disk to FSLogix Profile Container

.DESCRIPTION
Test before using!!

.NOTES
  Version:          1.0
  Author:           
  Rewrite Author:   Manuel Winkel <www.deyda.net>
  Creation Date:    2020-03-04
  Purpose/Change:
#>
#########################################################################################
# Setup Parameter first here UPDPath NewProfilePath DiskProfileFolder UserListe Users
# Requires -RunAsAdministrator
# My Userprofiles come only with SAMAccount Name without Domain "\Username\2012R2\UPM_Profile
#########################################################################################
# Example from my UPM Path "\\path_to_your_share\upd$\Profile"
# fslogix Root profile path
$NewProfilePath = '\\path_to_your_share\fslogix$'
# Profile Disk Root profile path
$UPDPath = '\\path_to_your_share\upd$\'
# Disk Profile Folder - First Path to Disk Profile Folder - see my example above
$DiskProfileFolder = 'Profile'
#Define the path to the user list and read it
$UserListe = 'C:\temp\UserMigrate.txt'
$Users = Get-Content $UserListe

#########################################################################################
# Do not edit here
#########################################################################################

foreach ($U in $Users){
	# User from the file corresponds to SAM
    $SAM = $U
	# Read SID based on SAM
    $SID = (New-Object System.Security.Principal.NTAccount($SAM)).translate([System.Security.Principal.SecurityIdentifier]).Value
	# Defining the path to the original UPD
    $UPD = Join-Path -Path $UPDPath -ChildPath ('UVHD-' + $SID + '.vhdx')
    Write-Output "Start with User: $SAM"
    If (Test-Path $UPD){
		# If UPD file exists, define target path
        $FSLPath = Join-Path -Path $NewProfilePath -ChildPath ($SAM + '_' + $SID)
		# Create the destination folder
        If (!(Test-Path $FSLPath)){
            Write-Output "Create Folder: $FSLPath"
            New-Item -Path $NewProfilePath -Name ($SAM + '_' + $SID) -ItemType Directory | Out-Null
        }
		# Set permissions from destination folder
        &amp; icacls $FSLPath /setowner "$env:userdomain\$sam" /T /C | Out-Null
        &amp; icacls $FSLPath /grant $env:userdomain\$sam`:`(OI`)`(CI`)F /T | Out-Null

		# Define destination file path
        $FSLDisk = Join-Path -Path $FSLPath -ChildPath ('Profile_' + $SAM + '.vhdx')
        # Copy profile disk to new destination
		Write-Output "Copy UPD: $UPD"
        Copy-Item -Path $UPD -Destination $FSLDisk | Out-Null
        # Mound Disk Image
		Mount-DiskImage -ImagePath $FSLDisk
		# Get drive letter
        $DriveLetter = (Get-DiskImage -ImagePath $FSLDisk | Get-Disk | Get-Partition).DriveLetter
        $MountPoint = ($DriveLetter + ':\')
        
		# Define path in the profile disk
        $DiskProfilePath = Join-Path -Path $MountPoint -ChildPath $DiskProfileFolder
		# Create path in the profile disk
        If (!(Test-Path $DiskProfilePath)){
            Write-Output "Create Folder: $DiskProfilePath"
            New-Item $DiskProfilePath -ItemType Directory| Out-Null
        } 
		
		# Defining the files and folders that should not be copied
        $Excludes = @("Profile","Uvhd-Binding","`$RECYCLE.BIN","System Volume Information")
		
		# Copy profile disk content to the new profile folder
        $Content = Get-ChildItem $MountPoint -Force
        ForEach ($C in $Content){
            
            If ($Excludes -notcontains $C.Name){
                Write-Output ('Move: ' + $C.FullName)
                
                Try {
                    Move-Item $C.FullName -Destination $DiskProfilePath -Force -ErrorAction Stop
                } Catch {
                    Write-Warning "Error: $_"
                }
            }

        }

# Defining the registry file
$regtext = "Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID]
`"ProfileImagePath`"=`"C:\\Users\\$SAM`"
`"Flags`"=dword:00000000
`"State`"=dword:00000000
`"ProfileLoadTimeLow`"=dword:00000000
`"ProfileLoadTimeHigh`"=dword:00000000
`"RefCount`"=dword:00000000
`"RunLogonScriptSync`"=dword:00000001
"
		
		# Create the folder and registry file
        Write-Output "Create Reg: $DiskProfilePath\AppData\Local\FSLogix\ProfileData.reg"  
        if (!(Test-Path "$DiskProfilePath\AppData\Local\FSLogix")) {
	        New-Item -Path "$DiskProfilePath\AppData\Local\FSLogix" -ItemType directory | Out-Null
        }
        if (!(Test-Path "$DiskProfilePath\AppData\Local\FSLogix\ProfileData.reg")) {
	        $regtext | Out-File "$DiskProfilePath\AppData\Local\FSLogix\ProfileData.reg" -Encoding ascii
        }

        # Remove OST, sometimes there is an issue, so you can prevent.
        remove-item $DiskProfilePath\AppData\Local\Microsoft\Outlook\*.ost

		# Short delay and unmound the disk image
        Start-Sleep -Seconds 30
        Dismount-DiskImage -ImagePath $FSLDisk


    }
        Write-Output "--------------------------------------------------------------------"
}
