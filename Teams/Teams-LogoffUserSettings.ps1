# Hide powershell prompt
Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle,0)

$ErrorActionPreference = 'SilentlyContinue'

# Optimize Microsoft Teams
$JsonFile = [System.IO.Path]::Combine($env:AppData, 'Microsoft', 'Teams', 'desktop-config.json')

If (Test-Path -Path $JsonFile) {
    $ConfigFile = Get-Content -Path $JsonFile -Raw | ConvertFrom-Json
    Get-Process -Name Teams | Stop-Process -Force
    $ConfigFile.appPreferenceSettings.disableGpu = $True
    $ConfigFile.appPreferenceSettings.openAtLogin = $True
    $ConfigFile.appPreferenceSettings.openAsHidden = $True
    $ConfigFile.appPreferenceSettings.runningOnClose = $True
    $ConfigFile.appPreferenceSettings.registerAsIMProvider = $True
    $ConfigFile | ConvertTo-Json -Compress | Set-Content -Path $JsonFile -Force 
} Else {
    Write-Host  "JSON file doesn't exist"
}