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

Path to the FSLogix Container Location

.PARAMETER target

Path to the new FSLogix Container Location. If not set, the source (path) is used as target.

.PARAMETER tmp

Path for the temporary storage. By Default it's C:\Windows\Temp\Script

.PARAMETER delete

Delete the source Differnce Disk FSLogix Container.

.PARAMETER recurse

Gets the disks in the specified locations and in all child items of the locations

.PARAMETER count

Number of created session containers.

.EXAMPLE

& '.\FSLogix-DiffDiskToUniqueDisk.ps1 -path "D:\CTXFslogix\" -Recurse -tmp D:\TMP

Copy and rename the disks in the specified locations and in all child items from Path D:\CTXFSLogix, with temporary storage in D:\TMP and create 1 session disk.

.EXAMPLE

& '.\FSLogix-DiffDiskToUniqueDisk.ps1 -path "D:\CTXFslogix\" -Recurse -count 9 -delete

Copy and rename the disks in the specified locations and in all child items from Path D:\CTXFSLogix, and create 9 session disk. After that the original Difference Container are deleted
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
        [System.String]$tmp = "C:\Windows\Temp\Script",
    
        [Parameter(
            HelpMessage='Container in the specified locations and in all child items of the locations'
        )]
        [Switch]$Recurse
    
    )


#$path = "D:\Friedhof\Spielwiese"
#$tmp = "D:\TMP"
#$target = "D:\Friedhof\Folder2"

if (!$target){
    $target = $path
}

$tmpall = $tmp+"\*"
$pathall = $path+"\*"

if ($Recurse) {
    
    if ($count -ge 1) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-0.VHDX") } 
    }
    if ($count -ge 2) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-1.VHDX") } 
    }
    if ($count -ge 3) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-2.VHDX") } 
    }
    if ($count -ge 4) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-3.VHDX") } 
    }
    if ($count -ge 5) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-4.VHDX") } 
    }
    if ($count -ge 6) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-5.VHDX") } 
    }
    if ($count -ge 7) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-6.VHDX") } 
    }
    if ($count -ge 8) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-7.VHDX") } 
    }
    if ($count -ge 9) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-8.VHDX") } 
    }
    if ($count -ge 10) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Recurse -Force
        Get-ChildItem -Path $tmp -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX -Recurse | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-9.VHDX") } 
    }
    Copy-Item -Path $tmpall -Destination $target -Recurse -Force
    Remove-Item $tmpall -Recurse
    Get-ChildItem –Path $path -Recurse -Filter *.VHDX -Exclude *-SESSION-*.VHDX | Foreach-Object {
        $PathACL = $($_.Directory)
        $ContainerName = $($_.Name)
        $parts = $ContainerName.split(".")
        $SessionName = $parts[0]+"-SESSION-0."+$parts[1]
        Get-ChildItem –Path $target -Recurse -Filter $SessionName | Foreach-Object {
        $TargetACL = $($_.Directory)}
        $PathACLPlus = ""+$PathACL+"\*.VHDX"
        $TargetACLPlus = ""+$TargetACL+"\*.VHDX"
        Get-Acl -Path $PathACLPlus -exclude *-SESSION-*.VHDX | Set-Acl -Path $TargetACLPlus
        }
    if ($Delete){
        Remove-Item $pathall -exclude *-SESSION-* -Recurse
    }
}
else {
        
    if ($count -ge 1) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-0.VHDX") } 
    }
    if ($count -ge 2) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-1.VHDX") } 
    }
    if ($count -ge 3) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-2.VHDX") } 
    }
    if ($count -ge 4) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-*-Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX| ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-3.VHDX") } 
    }
    if ($count -ge 5) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-4.VHDX") } 
    }
    if ($count -ge 6) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-5.VHDX") } 
    }
    if ($count -ge 7) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-6.VHDX") } 
    }
    if ($count -ge 8) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-7.VHDX") } 
    }
    if ($count -ge 9) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-8.VHDX") } 
    }
    if ($count -ge 10) {
        Copy-Item -Path $pathall -Destination $tmp -exclude *-SESSION-* -Force
        Get-ChildItem -Path $tmpall -Include *vhdx -exclude *-SESSION-* -Filter *.VHDX | ForEach-Object { Rename-Item $_ -NewName $_.Name.Replace(".VHDX","-SESSION-9.VHDX") } 
    }
    Copy-Item -Path $tmpall -Destination $target -Force
    Remove-Item $tmpall
    Get-ChildItem –Path $path -Recurse -Filter *.VHDX -Exclude *-SESSION-*.VHDX | Foreach-Object {
        $PathACL = $($_.Directory)
        $ContainerName = $($_.Name)
        $parts = $ContainerName.split(".")
        $SessionName = $parts[0]+"-SESSION-0."+$parts[1]
        Get-ChildItem –Path $target -Recurse -Filter $SessionName | Foreach-Object {
        $TargetACL = $($_.Directory)}
        $PathACLPlus = ""+$PathACL+"\*.VHDX"
        $TargetACLPlus = ""+$TargetACL+"\*.VHDX"
        Get-Acl -Path $PathACLPlus -exclude *-SESSION-*.VHDX | Set-Acl -Path $TargetACLPlus
        }
    if ($Delete){
        Remove-Item $pathall -exclude *-SESSION-* -Recurse
    }
}


