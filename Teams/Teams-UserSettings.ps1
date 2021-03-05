<#
.SYNOPSIS
This script allows you to define the Teams settings per user

.DESCRIPTION
Define the Teams settings.

.NOTES
  Version:         1.2
  Original Author: D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus7
  Rewrite Author:  Manuel Winkel <www.deyda.net>
  Creation Date:   2020-11-30
  Purpose/Change:  Added more Teams settings
  
 .EXAMPLE
  WEM:
  Path: powershell.exe
  Arguments: -executionpolicy bypass -file Teams-UserSettings.ps1" 
#>

#Define settings
param(
#Enable or disable GPU acceleration
[boolean]$disableGpu=$True,
#Fully close Teams App
[boolean]$runningOnClose=$False,
#Auto-start application
[boolean]$openAtLogin=$False,
#Register Teams as the default chat app for office
[boolean]$registerAsIMProvider=$False,
#Open Teams hidden
[boolean]$openAsHidden=$False
)

#Read Teams Configuration from desktop-config.json
$FileContent=Get-Content -Path "$ENV:APPDATA\Microsoft\Teams\desktop-config.json"

#Convert file to PowerShell object from desktop-config.json
$JSONObject=ConvertFrom-Json -InputObject $FileContent

#Update settings from desktop-config.json
$JSONObject.appPreferenceSettings.disableGpu=$disableGpu
$JSONObject.appPreferenceSettings.runningOnClose=$runningOnClose
$JSONObject.appPreferenceSettings.openAtLogin=$openAtLogin
$JSONObject.appPreferenceSettings.registerAsIMProvider=$registerAsIMProvider
$JSONObject.appPreferenceSettings.openAsHidden=$openAsHidden
$NewFileContent=$JSONObject | ConvertTo-Json

#Rewrite configuration to file from desktop-config.json
$NewFileContent | Set-Content -Path "$ENV:APPDATA\Microsoft\Teams\desktop-config.json" 