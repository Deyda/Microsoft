<# Delete all Files in a folder older than X day(s)

   @Deyda

#>

<#
.SYNOPSIS

Delete all Files in a folder older than X day(s) based on parameters

.PARAMETER path

Delay, in seconds, before the script starts checking for missing processes. Useful if something else is going to start the process

.PARAMETER days

The character used to separate the process from any optional arguments that need passing when the process is invoked if it is missing


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
Get-ChildItem $Path -Recurse ( | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item