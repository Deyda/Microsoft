<# Delete all Files in a folder older than X day(s)

   @Deyda

#>

<#
.SYNOPSIS

Delete all Files in a folder older than X day(s) based on parameters

.PARAMETER path

Path to the folder, where the files older than x day(s) are deleted

.PARAMETER days

Number of days that the files to be deleted are old. Default is 30 days


.EXAMPLE

'.\Microsoft-DeleteOldFiles.ps1'  -path "C:\temp" -days -15

#>

[CmdletBinding()]

Param
(
    [string]$path ,
    [int]$days = -30
)
 
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($days)

Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item