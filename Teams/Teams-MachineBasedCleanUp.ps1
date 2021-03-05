<#
.SYNOPSIS
This script allows you to uninstall the Microsoft Teams app and remove Teams directory for a user.

.DESCRIPTION
Use this script to clear the installed Microsoft Teams application. Run this PowerShell script for each user profile for which the Teams App was installed on a machine. After the PowerShell has executed on all user profiles, Teams can be redeployed.

.NOTES
  Version:        2.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-03-04
  Purpose/Change: Edit for Version 1.2.00.32462 and newer
#>


# Hide powershell prompt
Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle,0)

$TeamsUpdateExePathMachine = [System.IO.Path]::Combine('c:\Program Files (x86)', 'Microsoft', 'Teams', 'Update.exe')
$TeamsExePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
$TeamsExePathMachine = [System.IO.Path]::Combine('c:\Program Files (x86)', 'Microsoft', 'Teams')
$TeamsAppData = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft', 'Teams')
$TeamsAppData2 = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft Teams')
$TeamsLocalAppData = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
$SquirrelTemp = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'SquirrelTemp ')
$TeamsStartMenuShortcut = “c:\users\$env:USERNAME.$env:USERDOMAIN\Start Menu\Programs\Microsoft Corporation”
$TeamsDesktopShortcut = “c:\users\$env:USERNAME.$env:USERDOMAIN\Desktop\Microsoft Teams.lnk"
$TeamsPresenceAddinPathMachine = [System.IO.Path]::Combine('c:\Program Files (x86)', 'Microsoft', 'TeamsPresenceAddin')


try
{
    If (Test-Path -Path $TeamsExePathMachine) {
        Write-Host "Uninstalling Microsoft Teams Machine Based..."

        # Kill teams.exe
        If (Get-Process -Name Teams -ErrorAction SilentlyContinue) {
            Stop-Process -Name Teams -Force
        }
        
        #If (Test-Path -Path $TeamsUpdateExePathMachine) {
        #Write-Host "Uninstalling Microsoft Teams Machine Based..."
        # Uninstall app
        #$proc = Start-Process -FilePath $TeamsUpdateExePathMachine -ArgumentList "-uninstall -s" -PassThru -ErrorAction SilentlyContinue
        #$proc.WaitForExit()
        #}
        
        If (Test-Path -Path $TeamsExePathMachine) {
        Write-Host "Deleting Microsoft Teams Machine Based Install directory..."
        Get-ChildItem $TeamsExePathMachine -Recurse | Remove-Item
        Remove-Item $TeamsExePathMachine -Recurse -Force
        }

        # Delete Microsoft Teams AppData directory
        If (Test-Path -Path $TeamsAppData) {
            Write-Host "Deleting Microsoft/Teams AppData directory..."
            Get-ChildItem $TeamsAppData -Recurse | Remove-Item -Force
        }

        If (Test-Path -Path $TeamsAppData2) {
            Write-Host "Deleting Microsoft Teams AppData directory..."
            Get-ChildItem $TeamsAppData2 -Recurse | Remove-Item -Force 
        }

        # Delete Microsoft Teams LocalAppData directory
        If (Test-Path -Path $TeamsLocalAppData) {
            Write-Host "Deleting Microsoft Teams LocalAppData directory..."
            Get-ChildItem $TeamsLocalAppData -Recurse | Remove-Item -Force
        }

        # Delete Microsoft Teams SquirrelTemp directory
        If (Test-Path -Path $SquirrelTemp) {
            Write-Host "Deleting Microsoft Teams SquirrelTemp directory..."
            Get-ChildItem $SquirrelTemp -Recurse | Remove-Item -Force 
        }

        # Delete Microsoft Teams PresenceAddin directory
        If (Test-Path -Path $TeamsPresenceAddinPathMachine) {
            Write-Host "Deleting Microsoft Teams PresenceAddin directory..."
            Get-ChildItem $TeamsPresenceAddinPathMachine -Recurse | Remove-Item -Force 
            Remove-Item $TeamsPresenceAddinPathMachine -Recurse -Force
        }
        
        # Delete Microsoft Teams start menu shortcut
        If (Test-Path -Path $TeamsStartMenuShortcut) {
            Write-Host "Deleting Microsoft Teams start menu shortcut..."
            Remove-Item -Path $TeamsStartMenuShortcut -Recurse
        }

        # Delete Microsoft Teams desktop shortcut
        If (Test-Path -Path $TeamsDesktopShortcut) {
            Write-Host "Deleting Microsoft Teams desktop shortcut"
            Remove-Item -Path $TeamsDesktopShortcut -Recurse
        }
        

    }
}
catch
{
    Write-Error -ErrorRecord $_
    Exit 1
}
