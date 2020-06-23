<#
    .SYNOPSIS
        Mounts the UPD Profile [VHD/x] as a disk in system and creates an object with results of the drive letter and file path mounted file 
  
    .DESCRIPTION
        Checks if .vhdx file exists and mounts the UPD Profile (VHD) as a disk in system with random drive letter. 
        After successful mount operation the function will return an object with two keys: DriveLetter, VHDX 

    .PARAMETER VHDX
        Path to .vhdx file  

    .EXAMPLE
        Get-UPDProfile -ProfilePath E:\UPDProfiles | Mount-UPDProfile

        Drive VHDX                                                                   
        ----- ----                                                                   
        G:\   E:\UPDProfiles\UVHD-S-1-5-21-3286950516-3440391731-2706545478-1155.vhdx
        H:\   E:\UPDProfiles\UVHD-S-1-5-21-3286950516-3440391731-2706545478-1195.vhdx
        I:\   E:\UPDProfiles\UVHD-S-1-5-21-3286950516-3440391731-2706545478-1199.vhdx
        J:\   E:\UPDProfiles\UVHD-S-1-5-21-3286950516-3440391731-2706545478-1246.vhdx

    .NOTES
        Author: Jakub Podoba
        Last Edit: 06/18/2019

    #>
Function Mount-UPDProfile {

    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [object]$ProfilePath
    )
    
    Begin {
        $OutputObject = @()
    }
    
    Process {
        $VHDX = $ProfilePath
        if ($pscmdlet.ShouldProcess($Name, 'Action')) {

            Write-Output "Checking if file $VHDX exists." | Write-Log -LogPath $LogPath
            if ((Test-Path -Path $VHDX) -eq $True) {
                Write-Output "File $VHDX exists." | Write-Log -LogPath $LogPath

                try {
                    Write-Output "Mounting the file $VHDX" | Write-Log -LogPath $LogPath
                    $DriveLetter = (Mount-VHD -Path $VHDX -PassThru | Get-Disk | Get-Partition | select -Last 1).DriveLetter
                    Write-Output "File $VHDX mounted successfully." | Write-Log -LogPath $LogPath
                    Write-Output "Mounted to $driveletter`:\" | Write-Log -LogPath $LogPath
                }
                catch {
                    Write-Error "Unable to mount $VHDX, because following error: `n$_" 2>&1 | Write-Log -LogPath $LogPath
                }

                $Item = New-Object system.object
                $Item | Add-Member -Type NoteProperty -Name Drive -Value "$DriveLetter`:\"
                $Item | Add-Member -Type NoteProperty -Name VHDX -Value $VHDX
                $OutputObject += $Item

            }
            else {
                Write-Error "$VHDX file does not exist" 2>&1 | Write-Log -LogPath $LogPath
            }
        }
    }

    End {
        $OutputObject
    }
}