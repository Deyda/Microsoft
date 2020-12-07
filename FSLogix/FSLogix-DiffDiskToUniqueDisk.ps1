#requires -version 3
<#
.SYNOPSIS
Copy FSLogix Container from Difference Disk to Unique Disk per Session
.DESCRIPTION
Copy and rename existing VHDX container. After renaming, copy the new container to the original destination.
.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-12-07
  Purpose/Change:
<#


.PARAMETER path

Only include partitions whose label matches this regular expression. They are typically labelled "Profile-%username%"

.PARAMETER tmp

Do not iterate over the mounted disks contents to calculate how much data they contain.

.PARAMETER delete

Do not iterate over the mounted disks contents to calculate how much data they contain.

.EXAMPLE

& '.\FSLogix-DiffDiskToUniqueDisk.ps1' -path D:\CTXFSLogix -tmp D:\TMP

Copy and rename from Path D:\CTXFSLogix, with temporary storage in D:\TMP

#>

[CmdletBinding()]


Param (
    
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true,
            HelpMessage='FSLogix Container Source Path'            
        )]
        [System.String]$path,
    
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            HelpMessage='Delete Original Difference Disk Container'
        )]
        [switch]$delete,
    
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            HelpMessage='Path for Temporary Storage'
        )]
        [System.String]$tmp = "C:\Windows\Temp\Script"
    )


#$path = "D:\CTXFslogix"
#$tmp = "D:\TMP"



$tmpall = $tmp+"\*"
$pathall = $path+"\*"

Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-0.VHDX") } 
Copy-Item -Path $tmpall -Destination $path -Recurse -Force
Remove-Item $tmpall -Recurse