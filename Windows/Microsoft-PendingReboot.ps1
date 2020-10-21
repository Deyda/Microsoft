<#
        .SYNOPSIS
        Checks Remote Status of Pending Reboot

        .DESCRIPTION
        ###

        .PARAMETER Computer
        Remote Computer to be checked

        .PARAMETER List
        List of Remote Computer to be checked (not yet implemented)

        .PARAMETER Export
        Export to path with the computer as name
        
        .PARAMETER PassThru
        Returns an object representing the item with which you are working. By default, this cmdlet does not generate any pipeline output.

        .INPUTS
        You can pipe the computer into the command which is recognised by type, you can also pipe any parameter by name. It will also take the path positionally

        .OUTPUTS
        This script outputs a csv file with the result of the processing.  It will optionally produce a custom object with the same information

        .EXAMPLE
        Microsoft-MissingUpdates.ps1 -Computer ADC01
	    This checks a single a single computer and displays the result in the powershell window

        .EXAMPLE
        Microsoft-MissingUpdates.ps1 -Computer ADC01 -Export c:\
	    This checks a single a single computer and and export the result to C:\ADC01.txt
        
    #>
function Test-PendingReboot {
    if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
    if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
    try { 
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if (($status -ne $null) -and $status.RebootPending) {
            return $true
        }
    }
    catch { }

    return $false
}

Test-PendingReboot