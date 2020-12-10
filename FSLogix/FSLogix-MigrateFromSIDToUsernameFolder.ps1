#requires -version 3
<#
.SYNOPSIS
Migrate FSLogix Container vom Folder Name Schema SID_USERNAME to USERNAME_SID
.DESCRIPTION
If you don't set the more readable naming schema (USERNAME_SID) directly, you can't just do this afterwards.
Because it creates new folders and there, if not migrated before, new containers.
Therefore copy the existing containers to the new location before.
.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-12-09
  Purpose/Change:
<#


.PARAMETER path

Path to the old FSLogix Container Location

.PARAMETER target

Path to the new FSLogix Container Location. If not set, the source (path) is used as target.

.PARAMETER tmp

Path for the temporary storage. By Default it's C:\Windows\Temp\Script

.PARAMETER delete

Delete the source Disk Folder.


.EXAMPLE

& '.\FSLogix-MigrateFromSIDToUsernameFolder.ps1 -path "D:\CTXFslogix\" -tmp D:\TMP

Copy the disks in the specified locations (New Naming Schema) and in all child items from Path D:\CTXFSLogix, with temporary storage in D:\TMP.

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
            HelpMessage='Delete Original Folder'
        )]
        [switch]$delete,
    
        [Parameter(
            HelpMessage='Path for Temporary Storage'
        )]
        [System.String]$tmp = "C:\Windows\Temp\Script"
    
    )



#$target="D:\Friedhof\Folder3"
#$path="D:\Friedhof\Spielwiese\*"
#$tmp = "D:\TMP"

if (!$target){
    $target = $path
}
$regex1 = $target -match [regex] "\\$"
if ($regex1 -eq $False){
$target = $target+"\"}

$regex2 = $path -match [regex] "\*$"
if ($regex2 -eq $False){
    $regex3 = $path -match [regex] "\\\*$"
    if ($regex3 -eq $False){
    $path = $path+"\*"}
    else{
        $path = $path+"*"}}

Get-ChildItem -recurse $path -ErrorAction SilentlyContinue | Foreach-Object {
$pathnew = "$($_.directory)"
$path1 = $pathnew+"\*"
$partcount = ([regex]::Matches($path1, "\\" )).count
$parts = $pathnew.split("\")
$destdriss = $parts[$partcount-1]
$destcount = ([regex]::Matches($destdriss, "_" )).count
$partsdest = $destdriss.split("_")
if ($destcount -eq 1){
$destnew = $target+$partsdest[1]+"_"+$partsdest[0]
}
if ($destcount -eq 2){
$destnew = $target+$partsdest[1]+"_"+$partsdest[2]+"_"+$partsdest[0]
}
if ($destcount -eq 3){
$destnew = $target+$partsdest[1]+"_"+$partsdest[2]+"_"+$partsdest[3]+"_"+$partsdest[0]
}
    if(!(Test-Path -path $destnew))  
        {New-Item -ItemType directory -Path $destnew             
        }
move-item -Path $path1 -Destination $destnew -ErrorAction SilentlyContinue
}
    if ($Delete){
        Remove-Item  -Recurse
    }