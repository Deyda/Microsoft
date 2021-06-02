
<#
.SYNOPSIS
This script allows you to define the Teams settings per user

.DESCRIPTION
Define the Teams settings.

.NOTES
  Version:         1.3
  Author:  Manuel Winkel <www.deyda.net>
  Creation Date:   2020-11-30
  Purpose/Change:  Added more Teams settings
  31.05.2021 Matthias Schlimm/EUCweb: test if desktop-config.json exists and create it with default values or updating the existing one. Added Powershell Transcript
  
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
[boolean]$runningOnClose=$true,
#Auto-start application
[boolean]$openAtLogin=$False,
#Register Teams as the default chat app for office
[boolean]$registerAsIMProvider=$False,
#Open Teams hidden
[boolean]$openAsHidden=$true
)


$ConfigFile = "$ENV:APPDATA\Microsoft\Teams\desktop-config.json"
start-transcript $env:appdata\Set-Teams-UserSettings.log
Write-Host "--- Teams Settings --- "
Write-Host "disableGpu=$disableGpu"
Write-Host "runningOnClose=$runningOnClose"
Write-Host "openAtLogin=$openAtLogin"
Write-Host "registerAsIMProvider=$registerAsIMProvider"
Write-Host "openAsHidden=$openAsHidden"

#Read Teams Configuration from desktop-config.json
IF (Test-path $ConfigFile ) {
	Write-Host "Get Content from File $ConfigFile" 
	#Convert file to PowerShell object from desktop-config.json
	$JSONObject=Convertfrom-Json -inputobject (Get-Content $ConfigFile -Raw)
	
    Write-Host "Update Teams Settings" 
	#Update settings from desktop-config.json
	$JSONObject.appPreferenceSettings.disableGpu=$disableGpu
	$JSONObject.appPreferenceSettings.runningOnClose=$runningOnClose
	$JSONObject.appPreferenceSettings.openAtLogin=$openAtLogin
	$JSONObject.appPreferenceSettings.registerAsIMProvider=$registerAsIMProvider
	$JSONObject.appPreferenceSettings.openAsHidden=$openAsHidden
	
    #Rewrite configuration to file from desktop-config.json
	$NewFileContent=$JSONObject | ConvertTo-Json | Set-Content -Path $ConfigFile

} Else {
	$TeamsPath = [System.IO.Path]::GetDirectoryName($ConfigFile)
    IF (!(Test-Path $TeamsPath)) {
         Write-Host "Path $TeamsPath doesn't exist, creating Directory"
         New-Item -ItemType Directory -Path $TeamsPath
    }
    Write-Host "File $ConfigFile doesn't exist, creating it with default settings"
	$jsonBase = @{}
	$JsonDefaultData = @{}

	$JsonDefaultData = @{
		"disableGpu"=$disableGpu;
		"runningOnClose"=$runningOnClose;
		"openAtLogin"=$openAtLogin;
		"registerAsIMProvider"=$registerAsIMProvider;
		"openAsHidden"=$openAsHidden;
	}
	
	$jsonBase.Add("appPreferenceSettings",$JsonDefaultData)
    $jsonBase.Add("theme","Default")
	$jsonBase | ConvertTo-Json -Depth 10 | Out-File $ConfigFile -encoding ASCII
}

Stop-Transcript

