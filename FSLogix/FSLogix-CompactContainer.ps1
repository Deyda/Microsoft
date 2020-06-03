#Requires -RunAsAdministrator
<#
*************************************************************************************************************************************
Name:               Compact-Container
Author:             Kasper Johansen
Website:            https://virtualwarlock.net
Version:            1.0            
Last modified by:   Kasper Johansen
Last modified Date: 04-03-2020

*************************************************************************************************************************************

.SYNOPSIS
    This script shrinks/compacts and defragments VHD/VHDX files, reclaiming whitespace within the VHD/VHDX file.

.DESCRIPTION
    This script can be configured to run at a regular basis on a file server hosting
    FSLogix Profile Container and/or Office 365 Containers. 
    
    Running this script with a UNC path has not been tested, but it should be possible.
    
    The script has been tested on a Windows Server 2016/2019 file server only, 
    it's not guarenteed to work on older operating systems. 
    
    The script will obviously only be able to do it's thing while the container is not in use, 
    and the script requires administrative permissions.

.PARAMETER $ContainerDir
    The local path to the share where any FSLogix containers are stored.

.EXAMPLES
    Compact/Shrink all FSLogix Containers in E:\FSLogix\Profiles:
            FSLogix-CompactContainer.ps1 -ContainerDir "E:\FSLogix\Profiles"

*************************************************************************************************************************************
#>

param(
     [Parameter(Mandatory = $true)]
     [string]$ContainerDir
     )

# Test if specified VHD/VHDX directory exists.
function Get-Container
    {
    $Dir = $ContainerDir
    
    If (!(Test-Path -Path $Dir))
    {
        Write-Host "$Dir does not exist"
        Break
    }
        else
        {
            Get-ChildItem -Path $Dir -Recurse -Include "*.VHD","*.VHDX"
        }    
    }

# Get the Profile Container or Office 365 Container volume
function Get-ContainerVolume
    {
        Get-Volume | where {($_.FileSystemLabel -like "Profile*") -or ($_.FileSystemLabel -like "O365*")}
    }

# Create diskpart config file
function Create-DiskpartConfig
    {
    param(
         $DiskpartConfig,
         $DiskpartVHD
         )
             New-Item -Path $DiskpartConfig -ItemType File -Verbose
             Add-Content -Path $DiskpartConfig -Value "select vdisk file=`"$DiskpartVHD`""
             Add-Content -Path $DiskpartConfig -Value "attach vdisk readonly"
             Add-Content -Path $DiskpartConfig -Value "Compact vdisk"
             Add-Content -Path $DiskpartConfig -Value "detach vdisk"
             Add-Content -Path $DiskpartConfig -Value "exit"            
    }

# Mounts and optimizes the container
function Defrag-Container
    {
    param(
         $Container
         )
             Mount-DiskImage -ImagePath $Container -NoDriveLetter -Verbose
             #$VolumeLabel = (Get-Volume | where {($_.FileSystemLabel -like "Profile*") -or ($_.FileSystemLabel -like "O365*")})
             ForEach ($Volume in Get-ContainerVolume)
             {
                Optimize-Volume -FileSystemLabel $Volume.FileSystemLabel -Defrag -Verbose
             }
                    Dismount-DiskImage -ImagePath $Container -Verbose
    }

<#
function Get-MountedContainer
    {
    Param(
         $VHD
         )
            Get-SmbOpenFile | Where-Object -Property ShareRelativePath -Match $VHD | select -Property Path
    }
#>

function Compact-Container
    {
        Start-Transcript -Path "transcript.log"
        If (Get-Container -gt 0)
        {
            # Optimizes and defrags any VHD/VHDX files found
            ForEach ($VHD in Get-Container)
            {
                $VHDName = $VHD.Name                
                $VHDParentDir = $VHD.Directory | select -Unique
                $VHDContainer = $VHD.fullname
                
                               
                # Break if differerencing disk is found
                If (Test-Path -Path "$VHDParentDir\RW.*")
                {
                    Write-Host "Differencing disk in use, compacting aborted"
                    Break
                }
                
                
                <#                
                If (Get-MountedContainer -VHD $VHDName -contains $VHDContainer)
                {
                    Write-Host "$VHD is in use - skipping"
                }
                #>
                else
                    {
                        # Create diskpart configuration file for each VHD/VHDX
                        $DiskpartConfig = $VHD.Name+"-CompactConfig.txt"
                        $DiskpartLog = $VHD.Name+"-diskpart.log"
                        Create-DiskpartConfig -DiskpartConfig $DiskpartConfig -DiskpartVHD $VHDContainer

                            try
                            {
                            Write-Host "Optimizing $VHD, please wait..." -Verbose
                            Defrag-Container -Container $VHDContainer
                
                                Write-Host "Compacting $VHD, please wait..." -Verbose
                                Start-Process -Wait "$env:windir\system32\diskpart.exe" -ArgumentList "/s $DiskpartConfig" -NoNewWindow -RedirectStandardOutput $DiskpartLog -Verbose
                    
                                    Remove-Item -Path $DiskpartConfig -Verbose
                            }
                            catch
                            {
                                Write-Output "$Error[0].Exception.GetType().FullName"
                                Write-Host "$VHD is currently in use"
                            }
                    }                
            }
        }
            else
            {
                Write-Host "No VHD or VHDX files exists in the specified location"
                Break
            }
        Stop-Transcript
    }

Compact-Container $ContainerDir
