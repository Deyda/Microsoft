#requires -version 3
<#
.SYNOPSIS
Migrate FSLogix Container vom Folder Name Schema USERNAME_SID to SID_USERNAME
.DESCRIPTION
If you don't set the default naming schema (SID_USERNAME) directly, you can't just do this afterwards.
Because it creates new folders and there, if not migrated before, new containers.
Therefore copy the existing containers to the new location before.
.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2024-05-15
  Purpose/Change:
<#


.PARAMETER path

Path to the old FSLogix Container Location

.PARAMETER target

Path to the new FSLogix Container Location. If not set, the source (path) is used as target.

.PARAMETER delete

Delete the source Disk Folder.

.PARAMETER copy

Copy the source Disk Folder.

.EXAMPLE

& '.\FSLogix-MigrateFromUsernameToSIDFolder.ps1 -path D:\CTXFslogix -target D:\FSLogixCTX

Copy the disks in the specified locations (New Naming Schema) and in all child items from Path D:\CTXFSLogix to D:\FSLogixCTX

#>

[CmdletBinding()]


Param (

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'FSLogix Container Source Path'
    )]
    [System.String]$path,

    [Parameter(
        HelpMessage = 'FSLogix Container Target Path'
    )]
    [System.String]$target,

    [Parameter(
        HelpMessage = 'Delete Original Folder'
    )]
    [switch]$delete,

    [Parameter(
        HelpMessage = 'Copy not move Original Folder'
    )]
    [switch]$copy
)


#Test for paths Error and exit if they are not present
If (!(Test-Path $path)){
    Write-Error "$path does not exist"
    break
}
If (!(Test-Path $target)) {
    Write-Error "$target does not exist"
    break
}

#Get all paths which end in vhdx and process them
Get-ChildItem -Recurse $path2 -Include *vhdx -ErrorAction SilentlyContinue | ForEach-Object {

    $vhdPath = $_
    $pathSource = $vhdPath.directory
    #Grab user name and sid using regex and swap them round warn and quit if no match
    if ((Split-Path -Path $pathSource -Leaf) -match "(.*?)_(.*)") {
        $newDirName = $matches[2] + '_' + $matches[1]
    }
    else {
        write-warning "$pathnew was not correct format"
        break
    }

    #create final path string
    $destnew = Join-Path $target $newDirName

    if (!(Test-Path -Path $destnew)) {
        New-Item -ItemType directory -Path $destnew
    }
    #move the disk
    if ($Copy) {
        Copy-Item -Path $vhdPath -Destination $destnew
    } else {
        Move-Item -Path $vhdPath -Destination $destnew
    }
    #set permissions
    Get-Acl -Path $pathSource | Set-Acl -Path $destnew

}
if ($Delete) {
    Remove-Item $path -Recurse
}
