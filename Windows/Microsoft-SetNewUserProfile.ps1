# Hide powershell prompt
Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle,0)

# Custom modules list
$Modules = @("ActiveDirectory")

# Install and import custom modules list
Foreach ($Module in $Modules) {
	If (-not(Get-Module -ListAvailable -Name $Module)) {Import-Module -Name $Module}
}

Function Get-ScriptDirectory {
    If ($psISE) {Split-Path $psISE.CurrentFile.FullPath}
    Else {$Global:PSScriptRoot}
}

# Variables Declaration
# Generic
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
$appScriptDirectory = Get-ScriptDirectory
$env:SEE_MASK_NOZONECHECKS = 1
$User = $env:USERNAME
$UserProperties = Get-ADUser -Filter {SamAccountName -like $User} -Properties SamAccountName, ProfilePath | Select-Object SamAccountName, ProfilePath
# Env specific
$FileShare1 = "\\mc50f004\DATAS ADMIN"
$FileShare2 = "\\mc50f004\datas adminqc"
$FileShare3 = "\\mc50f004\DATAS INFO"

# Backup Firefox bookmarks
New-Item -Path "$env:USERPROFILE\Documents\Firefox" -ItemType Directory -Force
If (Test-Path -Path "$($UserProperties.ProfilePath)AppData\Roaming\Mozilla\Firefox") {
    $FirefoxBookmarks = "$($UserProperties.ProfilePath)AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite"
    Copy-Item -Path $FirefoxBookmarks -Destination "$env:USERPROFILE\Documents\Firefox\places.sqlite" -Force -Recurse
}
ElseIf (Test-Path -Path "$FileShare1\$User\AppData\Roaming\Mozilla\Firefox") {
    $FirefoxBookmarks = "$FileShare1\$User\AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite"
    Copy-Item -Path $FirefoxBookmarks -Destination "$env:USERPROFILE\Documents\Firefox\places.sqlite" -Force -Recurse
}
ElseIf (Test-Path -Path "$FileShare2\$User\AppData\Roaming\Mozilla\Firefox") {
    $FirefoxBookmarks = "$FileShare2\$User\AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite"
    Copy-Item -Path $FirefoxBookmarks -Destination "$env:USERPROFILE\Documents\Firefox\places.sqlite" -Force -Recurse
}
ElseIf (Test-Path -Path "$FileShare3\$User\AppData\Roaming\Mozilla\Firefox") {
    $FirefoxBookmarks = "$FileShare3\$User\AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite"
    Copy-Item -Path $FirefoxBookmarks -Destination "$env:USERPROFILE\Documents\Firefox\places.sqlite" -Force -Recurse
}

# Detect Outlook Signnature location
If (Test-Path -Path "$($UserProperties.ProfilePath)AppData\Roaming\Microsoft\Signatures") {
    $OutlookSignature = "$($UserProperties.ProfilePath)AppData\Roaming\Microsoft\Signatures"
}
ElseIf (Test-Path -Path "$FileShare1\$User\AppData\Roaming\Microsoft\Signatures") {
    $OutlookSignature = "$FileShare1\$User\AppData\Roaming\Microsoft\Signatures"
}
ElseIf (Test-Path -Path "$FileShare2\$User\AppData\Roaming\Microsoft\Signatures") {
    $OutlookSignature = "$FileShare2\$User\AppData\Roaming\Microsoft\Signatures"
}
ElseIf (Test-Path -Path "$FileShare3\$User\AppData\Roaming\Microsoft\Signatures") {
    $OutlookSignature = "$FileShare3\$User\AppData\Roaming\Microsoft\Signatures"
}

# Copy and Assign Outlook Signature
If (Test-Path -Path $OutlookSignature\*.htm) {
    Copy-Item -Path $OutlookSignature -Destination "$env:APPDATA\Microsoft" -Force -Recurse
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Setup" -Name "First-Run" -Force
    $SigPath = (Get-ChildItem -Path "$env:APPDATA\Microsoft\Signatures\*.htm" | Select-Object -ExpandProperty Name).Split(".")[0]
    New-Item -Path "HKCU:\Software\Microsoft\Office\16.0\Common\MailSettings" -Value "default value" -Force
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Common\MailSettings" -Name "NewSignature" -Value $SigPath -PropertyType "String" -Force
    #New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Common\MailSettings" -Name "ReplySignature" -Value $SigPath -PropertyType "String" -Force
}
Else {
    Write-Verbose -Message 'No Outlook signatures was found.'
}

If (Get-Process | Where-Object Name -eq Outlook) {
    Write-Verbose -Message 'Outlook is already running. No action needed.'
    }
Else {
    $Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\OUTLOOK.EXE\'

    If (!(Test-Path -Path $Key)) {
        throw 'Path to Outlook executable not found.'

    } Else {
        $exe = (Get-ItemProperty -Path $Key).'(default)'
        If (Test-Path -Path $exe) {
            Write-Verbose -Message 'Starting Outlook application...'
            Start-Process -FilePath $exe -ArgumentList "/resetfoldernames /recycle"
        } Else {
            Throw 'Outlook executable not found.'
        }
    }
}


If (Get-Process | Where-Object name -eq OneDrive) {
    Write-Verbose -Message 'OneDrive is already running. Process will be killed.'
    Stop-Process -Name OneDrive -Force
}

If (!(Test-Path -Path "${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDrive.exe")) {
    throw 'Path to OneDrive executable not found.'
} 
Else {
    Write-Verbose -Message 'Starting OneDrive application...'
    Start-Process -FilePath "${env:ProgramFiles(x86)}\Microsoft OneDrive\OneDrive.exe" -ArgumentList "/background /setautostart"
} 