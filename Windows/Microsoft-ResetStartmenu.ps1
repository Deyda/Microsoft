<#
.FUNCTIONALITY
Resets Win10 start-menu left side and right-side
.SYNOPSIS
Left-side: Removes orphaned entries that appear randomly and when MS Store (Appx) based apps are cached inside FSLogix profiles, but removed from actual OS
Right-side (tile section):  performs resets based on build XML
.DESCRIPTION
Author owen.reynolds@procontact.ca & jonathan.pitre@procontact.ca
.EXAMPLE
./Reset-StartMenu.ps1
.NOTES
.Link
N/A
#>

Add-Type -AssemblyName System.Windows.Forms

#Button Legend
#                  OK 0
#            OKCancel 1
#    AbortRetryIgnore 2
#         YesNoCancel 3
#               YesNo 4
#         RetryCancel 5

#Icon legend
#                None 0
#                Hand 16
#               Error 16
#                Stop 16
#            Question 32
#         Exclamation 48
#             Warning 48
#            Asterisk 64
#         Information 64


$messageBoxTitle = "Windows Start Menu Reset"
$UserResponse = [System.Windows.Forms.MessageBox]::Show("Do you want to reset the Windows Start Menu to resolve issues with missing/invalid shortcuts?" , $messageBoxTitle, 4, 32)

If ($UserResponse -eq "YES" ) {

	Write-Host "Reseting windows left / right side Windows 10 icons/allignment"

	Copy-Item -Path "C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\Shell" -Force
	Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*$start.tilegrid$windows.data.curatedtilecollection.tilecollection' -Force -Recurse -ErrorAction SilentlyContinue

	Get-Process shellexperiencehost -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

	Write-Host "Pausing for for 3 seconds..."
	Start-Sleep -Seconds 3

	Remove-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ShellExperienceHost_cw5n1h2txyewy\TempState\StartUnifiedTileModelCache.dat" -Force -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\TempState\StartUnifiedTileModelCache.dat" -Force -ErrorAction SilentlyContinue

	Get-Process Explorer | Stop-Process -Force -ErrorAction SilentlyContinue
	[System.Windows.Forms.MessageBox]::Show("Windows Start Menu was reset!", $messageBoxTitle, 0, 64)
}
Else {
	Write-Host "No"
	Exit
}