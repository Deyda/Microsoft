    <#
    .SYNOPSIS
        This function creates the destination FSLogix Profile Folder and Disk.
    
    .DESCRIPTION
        This function takes input data of source, target, username, and maximum vhd size, and logical sector size.
        A VHD is created at the location specified in the Target parameter.
        The Username parameter is used to apply the appropriate permissions for the user logging into the profile after creation.
        
    
    .PARAMETER Target
        The VHD is created at the location specified in this parameter.
    
    .PARAMETER ProfilePath
        This parameter is used to take ownership of the source folder location. This will not run, and is currently commented out.
    
    .PARAMETER Username 
        Expects a SAM Account name. This is used to apply the appropriate permissions for the user logging into the profile after creation.

    .PARAMETER Size
        Specifies the maximum VHD/X size, in Gigabytes.

    .PARAMETER SectorSize
        Specifies the Logical Sector Size for the VHD/X. Options are 4K and 512.
        
    .EXAMPLE
        New-ProfileDisk -Target "\\Server\FSLogixProfiles$\S-1-5-21-726503766-34464521-262356478-12241_User1\Profile_User1.vhdx" -Username User1 -Size 15 -SectorSize 512

        The example above will create a dynamic VHDX with a maximum size of 15GB, and sector size of 512 at the target location. Then, it will grant permissions to it for User1.
        
    .NOTES
        Author: Dom Ruggeri
        Last Edit: 6/27/2019
    
    #>
    Function New-ProfileDisk {
        
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True)]
        [string]$Target,

        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$False)]
        [string]$ProfilePath,

        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True)]
        [string]$Username,

        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True)]
        [uint64]$Size,

        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$False)]
        [validateSet('4K','512')]
        [string]$SectorSize
        
    )
    
    Begin {
        $OutputObject = @()
        if ($SectorSize -eq '4K'){
            $SectorSizeBytes = 4096
        }
        if ($SectorSize -eq '512'){
            $SectorSizeBytes = 512
        }
        
        function New-FSLogixVHD ($Target,$Size,$SectorSizeBytes){
            Write-Output "Creating, formatting, and mounting VHD." 4>&1 | Write-Log -LogPath $LogPath
            $Size = ($Size * 1GB)
            New-VHD -path $Target -SizeBytes $Size -Dynamic -LogicalSectorSizeBytes $SectorSizeBytes |
            Mount-VHD -Passthru |  `
            get-disk -number {$_.DiskNumber} | `
            Initialize-Disk -PartitionStyle GPT -PassThru | `
            New-Partition -UseMaximumSize -AssignDriveLetter:$False | `
            Format-Volume -Confirm:$false -FileSystem NTFS -force | `
            get-partition | `
            Add-PartitionAccessPath -AssignDriveLetter -PassThru | `
            Dismount-VHD $Target -ErrorAction SilentlyContinue
        }

        function Mount-FSLogixVHD ($Target){
            Write-Output "Mounting VHD." 4>&1 | Write-Log -LogPath $LogPath
            Mount-VHD $Target
            $global:drive = (Get-DiskImage -ImagePath $Target | `
                Get-Disk | `
                Get-Partition).DriveLetter
            Get-PSDrive | Out-Null
        }
      
        <#  
        Function for grabbing folder size - no longer needed
      
        function Get-FolderSize {
            [CmdletBinding()]
            Param (
            [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
            $Path,
            [ValidateSet("KB","MB","GB")]
            $Units = "MB"
            )
              if ( (Test-Path $Path) -and (Get-Item $Path).PSIsContainer ) {
                Write-Output "Calculating Source Folder Size." 4>&1 | Write-Log -LogPath $LogPath
                $Measure = Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                $Sum = $Measure.Sum / "1$Units"
                [PSCustomObject]@{
                  "Path" = $Path
                  "Size" = $Sum
                }
              }
            }
        #>
    }
    
    Process {
        if ($pscmdlet.ShouldProcess($Name, 'Action')){
            if ($Target -ne "Cannot Copy"){
                if (!(Test-Path ($Target.Substring(0, $Target.LastIndexOf('.')) + "*"))) {
                    
                    <# 
                    Process for taking ownership of source profile
                    
                    $ProfilePath = $ProfilePath.TrimEnd("\")
                    Write-Output "Taking ownership of source - $ProfilePath" 4>&1 | Write-Log -LogPath $LogPath
                    takeown /f "$ProfilePath" /r /a /d Y
                    icacls "$ProfilePath" /grant administrators:f /t
                    takeown /f "$ProfilePath" /r /a /d Y
                    icacls "$ProfilePath" /grant administrators:f /t
                    #>
                    
                    <# 
                    Process for generating VHD size based on source size

                    [uint64]$Size = ((Get-FolderSize -Path $ProfilePath -Units MB).Size)
                    $Size = ($Size * 1MB) + 200MB 
                    #>

                    New-FSLogixVHD -Target $Target -Size $Size -SectorSizeBytes $SectorSizeBytes
                    icacls "$Target" /grant $Username`:f /t
                    Write-Output "Mounting VHD $Target" 4>&1 | Write-Log -LogPath $LogPath
                    Mount-VHD $Target -ErrorAction SilentlyContinue
                    $drive = (Get-DiskImage -ImagePath $Target | Get-Disk | Get-Partition).DriveLetter
                    sleep 6
                    if (($Drive | Measure-Object).count -gt 1){
                        $Drive = $drive[1]}
                    $Item = New-Object system.object
                    $Item | Add-Member -Type NoteProperty -Name Drive -Value "$drive`:\"
                    $Item | Add-Member -Type NoteProperty -Name Target -Value $Target
                    $OutputObject += $Item
                }
                else {
                    Write-Output "$($Target.Substring(0, $Target.LastIndexOf('.'))) already exists- Skipping." 4>&1 | Write-Log -LogPath $LogPath
                    Write-Output "$($Target.Substring(0, $Target.LastIndexOf('.'))) already exists- Skipping."
                }
            }
        }
    }
    
    End {
        $OutputObject
    }
}