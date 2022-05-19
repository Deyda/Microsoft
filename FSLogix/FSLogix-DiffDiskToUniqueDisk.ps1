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
  - New Parameter Count to create more than one Session Disk
  - New Parameter Target to create Session Disks on new place
<#


.PARAMETER path

Path to the FSLogix Container Location

.PARAMETER target

Path to the new FSLogix Container Location. If not set, the source (path) is used as target.

.PARAMETER tmp

Path for the temporary storage. By Default it's C:\Windows\Temp\Script

.PARAMETER delete

Delete the source Differnce Disk FSLogix Container.

.PARAMETER count

Number of created session containers.

.EXAMPLE

& '.\FSLogix-DiffDiskToUniqueDisk.ps1 -path D:\CTXFslogix -tmp D:\TMP -target D:\FSLogixCTX

Copy and rename the disks in the specified locations and in all child items from Path D:\CTXFSLogix to D:\FSLogixCTX, with temporary storage in D:\TMP and create 1 session disk.

.EXAMPLE

& '.\FSLogix-DiffDiskToUniqueDisk.ps1 -path D:\CTXFslogix -count 9 -delete

Copy and rename the disks in the specified locations and in all child items from Path D:\CTXFSLogix to D:\CTXFSLogix, and create 9 session disk. After that the original Difference Container are deleted
#>

[CmdletBinding()]


Param (
    
        [Parameter(
            Mandatory = $true,
            HelpMessage='FSLogix Container Source Path'            
        )]
        [System.String]$path,
    
        [Parameter(
            HelpMessage='FSLogix Container Target Path'            
        )]
        [System.String]$target,

        [Parameter(
            HelpMessage='Delete Original Difference Disk Container'
        )]
        [switch]$delete,
    
        [Parameter(
            HelpMessage='Number of created session containers.'
        )]
        [int]$count = 1 ,

        [Parameter(
            HelpMessage='Path for Temporary Storage'
        )]
        [System.String]$tmp = "C:\Windows\Temp\Script"
    
    )

If (!(Test-Path $tmp)) { New-Item -Path $tmp -ItemType directory | Out-Null }

$tmpall = $tmp+"/*"
Remove-Item $tmpall -Recurse

if (!$target){
    $target = $path
}

$regex1 = $target -match [regex] "\\$"
if ($regex1 -eq $False){
$target = $target+"\"}

$sources = Get-ChildItem $path | Select-Object -Expand fullname | Sort-Object | out-gridview -OutputMode Multiple -title "Select profile(s) to convert"
foreach ($source in $sources) {
    $sourceStrings = ([regex]::Matches($source, "\\" )).count
    $sam = $source.split("\\")[$SourceStrings]
    $tmpVHDX = $tmp+"\ODFC_"+$sam+".VHDX"
    $targetVHDX = $target + $sam
    $sourceVHDX = $source+"\ODFC_"+$sam+".VHDX"
    
    "Copying $sourceVHDX to $tmpvhdx"

    if ($count -ge 1) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-0.VHDX") } 
    }
    if ($count -ge 2) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-1.VHDX") } 
    }
    if ($count -ge 3) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-2.VHDX") } 
    }
    if ($count -ge 4) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-3.VHDX") } 
    }
    if ($count -ge 5) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-4.VHDX") } 
    }
    if ($count -ge 6) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-5.VHDX") } 
    }
    if ($count -ge 7) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-6.VHDX") } 
    }
    if ($count -ge 8) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-7.VHDX") } 
    }
    if ($count -ge 9) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-8.VHDX") } 
    }
    if ($count -ge 10) {
        Copy-Item -Path $sourceVHDX -Destination $tmp -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-9.VHDX") } 
    }

    "Copying $sam from $tmp to $targetvhdx"

    Copy-Item -Path $tmpall -Destination $targetVHDX -Recurse -Force

    "Delete $sam from $tmp"

    Remove-Item $tmpall -Recurse

    "Set ACL for new container from $sam"

    Get-ChildItem -Path $source -Recurse -Filter *.VHDX -Exclude *-SESSION-*.VHDX | Foreach-Object {
        $PathACL = $($_.Directory)
        $ContainerName = $($_.Name)
        $parts = $ContainerName.split(".")
        $SessionName = $parts[0]+"-SESSION-0."+$parts[1]
        Get-ChildItem -Path $target -Recurse -Filter $SessionName | Foreach-Object {
        $TargetAC = $($_.Directory)}
        $PathACLPlus = ""+$PathACL+"\*.VHDX"
        $TargetACLPlus = ""+$TargetAC+"\*.VHDX"
        Get-Acl -Path $PathACLPlus -exclude *-SESSION-*.VHDX | Set-Acl -Path $TargetACLPlus
        Get-Acl -Path $PathACLPlus | Set-Acl -Path $TargetAC
        }
    if ($Delete){

        "Delete $sourceVHDX"

        Remove-Item $sourceVHDX -exclude *-SESSION-* -Recurse
    }
    ""
}