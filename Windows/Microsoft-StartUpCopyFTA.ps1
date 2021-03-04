<#
.SYNOPSIS
    Copies FSLogix Rules from from a network location to the FSLogix Rule location on the local computer
.DESCRIPTION
    This script is used to copy FSLogix Rules from a network location to the FSLogix Rule location on the local computer.  The script is intended to be used with
    a GPO that runs the script at startup.  
    The script includes error handling that will write errors to the local Application Event Log.  Modify the Write Event Log variables as needed.
.NOTES
    Author      : Jonathan Pitre, original script by Travis Roberts www.ciraltos.com
    Version     : 1.1
#>

######## Variables ##########
# Source path for FSLogix App Masking rules
$sourcePath = "\\%DomainName%\NETLOGON\FSLogix\Rules"
# Destination path for FSLogix App Masking rules
$destinationPath = "$env:ProgramFiles\FSLogix\Apps\Rules"
# Source path for File Association XML
$sourcePath2 = "\\%DomainName%\NETLOGON\FileAssociation"
# Destination path for File Association XML
$destinationPath2 = "$env:winDir\system32"
######## Write Event Log ##########
# Set Variables
$eventLog = "Application"
$eventSource = "FSLogix Rules Copy"
$eventID = 4000
$entryType = "Error"

# Check if the source exists and create if needed
If ([System.Diagnostics.EventLog]::SourceExists($eventSource) -eq $False) {
    New-EventLog -LogName Application -Source $eventSource
}

# Write EventLog Function
Function Write-AppEventLog {
    Param($errorMessage)
    Write-EventLog -LogName $eventLog -EventID $eventID -EntryType $entryType -Source $eventSource -Message $errorMessage 
}

# Check the source path
if ((Test-Path $SourcePath) -eq $False) {
    write-AppEventLog 'Source path not found or not accessible'
}

# Check the destination path
If ((Test-Path $destinationPath) -eq $False) {
    Write-AppEventLog 'Destination path not found or not accessible'
}

# Copy the files to the destination
Try {
    Remove-Item $destinationPath\*.* -Force
    Copy-Item -ErrorAction Stop -Path "$sourcePath\*.fxa" -Destination $destinationPath -Force
    Copy-Item -ErrorAction Stop -Path "$sourcePath\*.fxr" -Destination $destinationPath -Force
}
Catch {
    $ErrorMessage = $_.Exception.message
    Write-AppEventLog $ErrorMessage
}


# Copy File Association xml
Copy-Item -ErrorAction Stop -Path "$sourcePath2\FileAssociation2019.xml" -Destination "$destinationPath2\FileAssociation.xml" -Force