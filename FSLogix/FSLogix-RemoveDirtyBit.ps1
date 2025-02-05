#Requires -RunAsAdministrator
<#
*************************************************************************************************************************************
Name:               FSLogix-RemoveDirtyBit
Author:             Manuel Winkel
Version:            1.1            
Last modified Date: 05-02-2025

*************************************************************************************************************************************

.SYNOPSIS
    This script cleans VHD/VHDX files with Dirty Bits. It is created specifically for FSLogix Containers.

.DESCRIPTION
    This script can clean any existing FSLogix Containers (VHD/VHDX) from Dirty Bits.
    
    Running this script with a UNC path has not been tested, but it should be possible.
    
    The script has been tested on a Windows Server 2019/2022 file server only, 
    it's not guarenteed to work on older operating systems. 
    
    The script will obviously only be able to do it's thing while the FSLogix Container is not in use, 
    and the script requires administrative permissions.

    !!DISCLAIMER!!
    Run this script a your own risk. I cannot be held responsible if anything goes wrong like corrupt or damaged containers.
    Like anything else TEST, TEST and TEST some more, before releasing to production!

.PARAMETER $ContainerDir
    The local path to the share where any FSLogix Containers are stored.

.PARAMETER $ContainerType
    The FSLogix Container type, either Profile or O365.

.EXAMPLES
    Cleans an existing FSLogix Profile Container:
    FSLogix-RemoveDirtyBit.ps1 -ContainerDir "E:\FSLogix\Profiles" -ContainerType Profile

*************************************************************************************************************************************
#>

param(
     [Parameter(Mandatory = $true)]
     [string]$ContainerDir,
     [Parameter(Mandatory = $true)][ValidateSet("Profile","O365")]
     [string]$ContainerType
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
        Get-Volume | where {($_.FileSystemLabel -like "$ContainerType-*")}
    }

# Create diskpart config file
function Create-DiskpartConfig
    {
    param(
         $DiskpartConfig,
         $DiskpartVHD,
         $DiskpartVHDVolume,
         $DiskpartVHDSize = $ContainerSize * 1KB 
         )
             New-Item -Path $DiskpartConfig -ItemType File -Verbose
             Add-Content -Path $DiskpartConfig -Value "select vdisk file=`"$DiskpartVHD`""
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
             ForEach ($Volume in Get-ContainerVolume)
             {
                Optimize-Volume -FileSystemLabel $Volume.FileSystemLabel -Defrag -Verbose
             }
                    Dismount-DiskImage -ImagePath $Container -Verbose
    }

# Mounts and expands the container
function DirtyBit-Container
    {
    param(
         $Container
         )
            Mount-DiskImage -ImagePath $Container -NoDriveLetter -Verbose
            ForEach ($Volume in Get-ContainerVolume)
                 {
                    $DiskNumber = Get-Disk | where {$_.Location -eq $VHDContainer} | select -ExpandProperty DiskNumber
                    Get-Partition -DiskNumber $DiskNumber | Set-Partition -NewDriveLetter Q
                    chkdsk Q: /F /R
                 }
                        Dismount-DiskImage -ImagePath $Container -Verbose    
    }
    function Expand-Container
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
                
                else
                    {
                        # Create diskpart configuration file for each VHD/VHDX
                        $DiskpartConfig = $VHD.Name+"-ExpandConfig.txt"
                        $DiskpartLog = $VHD.Name+"-diskpart.log"
                        Create-DiskpartConfig -DiskpartConfig $DiskpartConfig -DiskpartVHD $VHDContainer

                            try
                            {
                            #Write-Host "Optimizing $VHD, please wait..." -Verbose
                            #Defrag-Container -Container $VHDContainer
                
                                #Write-Host "Expanding $VHD, please wait..." -Verbose
                                #Start-Process -Wait "$env:windir\system32\diskpart.exe" -ArgumentList "/s $DiskpartConfig" -NoNewWindow -RedirectStandardOutput $DiskpartLog -Verbose
                                    
                                 #   Remove-Item -Path $DiskpartConfig -Verbose

                                  #      Write-Host "Expanding $VHD partition, please wait..." -Verbose
                                        DirtyBit-Container -Container $VHD

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
Set-Service -Name defragsvc -StartupType Manual
Expand-Container $ContainerDir $ContainerType
