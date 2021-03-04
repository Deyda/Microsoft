# PowerShell Wrapper for MDT, Standalone and Chocolatey Installation - (C)2020 Jonathan Pitre, inspired by xenappblog.com
# Example 1 Install EXE:
# Execute-Process -Path .\appName.exe -Parameters "/silent"
# Example 2 Install MSI:
# Execute-MSI -Action Install -Path appName.msi -Parameters "/QB" -AddParameters "ALLUSERS=1"
# Example 3 Uninstall MSI:
# Remove-MSIApplications -Name "appName" -Parameters "/QB"

#Requires -Version 5.1

# Custom package providers list
$PackageProviders = @("Nuget")

# Custom modules list
$Modules = @("PSADT", "Evergreen")

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Checking for elevated permissions...
If (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Write-Warning -Message "Insufficient permissions to continue! PowerShell must be run with admin rights."
	Break
}
Else {
	Write-Verbose -Message "Importing custom modules..." -Verbose

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

	# Install custom package providers list
	Foreach ($PackageProvider in $PackageProviders) {
		If (-not(Get-PackageProvider -ListAvailable -Name $PackageProvider -ErrorAction SilentlyContinue)) { Install-PackageProvider -Name $PackageProvider -Force }
	}

	# Add the Powershell Gallery as trusted repository
	Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

	# Update PowerShellGet
	$InstalledPSGetVersion = (Get-PackageProvider -Name PowerShellGet).Version
	$PSGetVersion = [version](Find-PackageProvider -Name PowerShellGet).Version
	If ($PSGetVersion -gt $InstalledPSGetVersion) { Install-PackageProvider -Name PowerShellGet -Force }

	# Install and import custom modules list
	Foreach ($Module in $Modules) {
		If (-not(Get-Module -ListAvailable -Name $Module)) { Install-Module -Name $Module -AllowClobber -Force | Import-Module -Name $Module -Force }
		Else {
			$InstalledModuleVersion = (Get-InstalledModule -Name $Module).Version
			$ModuleVersion = (Find-Module -Name $Module).Version
			$ModulePath = (Get-InstalledModule -Name $Module).InstalledLocation
			$ModulePath = (Get-Item -Path $ModulePath).Parent.FullName
			If ([version]$ModuleVersion -gt [version]$InstalledModuleVersion) {
				Update-Module -Name $Module -Force
				Remove-Item -Path $ModulePath\$InstalledModuleVersion -Force -Recurse
			}
		}
	}

	Write-Verbose -Message "Custom modules were successfully imported!" -Verbose
}

Function Get-ScriptDirectory {
	If ($PSScriptRoot) { $PSScriptRoot } # Windows PowerShell 3.0-5.1
	ElseIf ($psISE) { Split-Path $psISE.CurrentFile.FullPath } # Windows PowerShell ISE Host
	ElseIf ($psEditor) { Split-Path $psEditor.GetEditorContext().CurrentFile.Path } # Visual Studio Code Host
}

# Variables Declaration
# Generic
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
$env:SEE_MASK_NOZONECHECKS = 1
$appScriptDirectory = Get-ScriptDirectory

# Application related
##*===============================================

# Create PSDrive for HKU
New-PSDrive -PSProvider Registry -Name HKUDefaultHive -Root HKEY_USERS

# Load Default User Hive
Start-Process -FilePath CMD.EXE -ArgumentList "/C REG.EXE LOAD HKU\DefaultHive %SystemDrive%\Users\Default\NTUSER.DAT" -Wait -WindowStyle Hidden

# Set Sounds scheme to none
$RegKeys = Get-ChildItem -Path "HKUDefaultHive:\DefaultHive\AppEvents\Schemes\Apps\.Default" -Recurse | Select-Object -ExpandProperty name | ForEach-Object { $_ -replace "HKEY_USERS" , 'HKUDefaultHive:' }
ForEach ($i in $RegKeys) {
    Set-ItemProperty -Path $i -Name "(Default)" -Value ""
}

# Disable sound beep
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Sound" -Name "Beep" -Type String -Value "no"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Sound" -Name "ExtendedSounds" -Type String -Value "no"

# Force asynchronous processing of user GPOs at first logon - https://james-rankin.com/articles/make-citrix-logons-use-asynchronous-user-group-policy-processing-mode
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Group Policy\State" -Name "NextRefreshReason" -Value "0" -Type DWord
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Group Policy\State" -Name "NextRefreshMode" -Type DWord -Value 2

# Set display language
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "PreferredUILanguages" -Type MultiString -Value "fr-CA"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "PreferredUILanguagesPending" -Type MultiString -Value "fr-CA"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop\MuiCached" -Name "MachinePreferredUILanguages" -Type MultiString -Value "en-US"
Remove-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile" -Recurse -ContinueOnError $True
Remove-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile System Backup" -Recurse -ContinueOnError $True
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile" -Name "Languages" -Type MultiString -Value "fr-CA"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile" -Name "ShowAutoCorrection" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile" -Name "ShowCasing" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile" -Name "ShowShiftLock" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile" -Name "ShowTextPrediction" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile\fr-CA" -Name "0C0C:00001009" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\User Profile\fr-CA" -Name "CachedLanguageName" -Type String -Value "@Winlangdb.dll,-1160"

# Set display locale
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "Locale" -Type String -Value "00000C0C"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "LocaleName" -Type String -Value "fr-CA"

# Set Country
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "sCountry" -Type String -Value "Canada"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "sLanguage" -Type String -Value "FRC"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\Geo" -Name "Name" -Type String -Value "CA"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International\Geo" -Name "Nation" -Type String -Value "39"

# Set Internet Explorer language
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Internet Explorer\International" -Name "AcceptLanguage" -Type String -Value "fr-CA,en-CA;q=0.5"

# Set Keyboards
Remove-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Preload" -Recurse
Remove-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Substitutes" -Recurse

# Set French (Canada) - Canadian French keyboard layout
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Preload" -Name "1" -Type String -Value "00000c0c"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Substitutes" -Name "00000c0c" -Type String -Value "00001009"

# Set English (Canada) - US keyboard layout
#Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Preload" -Name "2" -Type String -Value "00001009"
#Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Substitutes" -Name "00001009" -Type String -Value "00000409"

# Disable input language switch hotkey -https://windowsreport.com/windows-10-switches-keyboard-language
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Toggle"  -Name "Hotkey" -Type DWord -Value "3"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Toggle"  -Name "Language Hotkey" -Type DWord -Value "3"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Keyboard Layout\Toggle"  -Name "Layout Hotkey" -Type DWord -Value "3"

# Hide the language bar
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\CTF\LangBar" -Name "ShowStatus" -Type DWord -Value "3"

# Set first day of week
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "iFirstDayOfWeek" -Type String -Value "0"

# Set date format
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "sLongDate" -Type String -Value "dddd dd MMMM yyyy"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "sShortDate" -Type String -Value "dd-MM-yyyy"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "sYearMonth" -Type String -Value "MMMM, yyyy"

# Set time format
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "sTimeFormat" -Type String -Value "HH:mm:ss"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\International" -Name "sShortTime" -Type String -Value "HH:mm"

# Disable action center
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value "0"

# Add "THIS PC" to desktop
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value "0"

# Advertising ID
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value "0"

# Set wallpaper
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "WallPaper" -Type String -Value ""
#Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "WallPaperStyle" -Type String -Value "10"

# Ddisables peer-to-peer caching but still allows Delivery Optimization to download content over HTTP from the download's original source - https://docs.microsoft.com/en-us/windows/deployment/update/waas-delivery-optimization-reference#download-mode
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode" -Type DWord -Value "3"

# Show known file extensions
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value "0"

# Change default explorer view to my computer
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value "1"

# Show Taskbar on one screen and show icons where taskbar is open
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarEnabled" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarMode" -Type DWord -Value "2"

# Show search box on the taskbar
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value "2"

# Disable Security and Maintenance Notifications
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" -Name "Enabled" -Type DWord -Value "0"

# Hide Windows Ink Workspace Button
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name "PenWorkspaceButtonDesiredVisibility" -Type DWord -Value "0"

# Disable Game DVR
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value "0"

# Disable the label "Shortcut To" on shortcuts
$ValueHex = "00,00,00,00"
$ValueHexified = $ValueHex.Split(",") | ForEach-Object { "0x$_"}
$ValueBinary = ([byte[]]$ValueHexified)
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "link" -Type Binary -Value $ValueBinary

# Show ribbon in File Explorer
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Policies\Microsoft\Windows\Explorer" -Name "ExplorerRibbonStartsMinimized" -Type DWord -Value "2"


# Hide Taskview button on Taskbar
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value "0"

# https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909
# Disable checkboxes File Explorer
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Type DWord -Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Type DWord -Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect " -Type DWord -Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListViewShadow" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowInfoTip" -Type DWord -Value "0"
# Visual effects - Disable "Animations in the taskbar" - https://virtualfeller.com/2015/11/19/windows-10-optimization-part-4-user-interface
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value "0"
# Hide People button from Taskbar
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ComboBoxAnimation" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ControlAnimations" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMAeroPeekEnabled" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMSaveThumbnailEnabled" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TaskbarAnimations" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation" -Name "DefaultApplied" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord-Value "0"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord-Value "0"

# Always show alll icons and notifications on the taskbar -   https://winaero.com/blog/always-show-tray-icons-windows-10
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value "0"

# System Optimization
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "AutoEndTasks" -Type String -Value "1"
# Optimizes Explorer and Start Menu responses Times - https://docs.citrix.com/en-us/workspace-environment-management/current-release/reference/environmental-settings-registry-values.html
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "InteractiveDelay" -Type DWord -Value "40"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "WaittoKillAppTimeout" -Type String -Value "2000"

# Visual Effects
# Settings "Visual effects to Custom" - https://support.citrix.com/article/CTX226368
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value "3"

# Change Windows Visual Effects - https://virtualfeller.com/2015/11/19/windows-10-optimization-part-4-user-interface
# https://superuser.com/questions/839993/find-registry-key-for-windows-8-per-application-input-method-setting
$ValueHex = "90,24,03,80,10,00,00,00"
$ValueHexified = $ValueHex.Split(",") | ForEach-Object { "0x$_"}
$ValueBinary = ([byte[]]$ValueHexified)
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "UserPreferencesMask" -Type $ValueBinary -Value "0"

# Specifies how much time elapses between each blink of the selection cursor
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "CursorBlinkRate" -Type String -Value "-1"

# Disables Cursor Blink
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "DisableCursorBlink" -Type DWord -Value "1"

# Visual effects - Disable "Show window contents while dragging"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value "0"

# Reduces the Start menu display interval
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value "10"

# Disable smooth scrolling
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop" -Name "SmoothScroll" -Type DWord-Value "0"

# Visual effects - Disable "Animate windows when minimizing and maximizing"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value "0"

# Expand to open folder"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -Type DWord -Value "1"

# Show all folers
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowAllFolders" -Type DWord -Value "1"

# Always Show Menus
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AlwaysShowMenus" -Type DWord -Value "1"

# Display Full Path in Title Bar
#Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value "1"

# Visual effects - Disable "Show thumbnails instead of icons"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value "0"
# Enable Thumbnail Previews
Remove-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableThumbnails"
Remove-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnails"

# Visual effects - Disable "Enable Peek" - https://www.tenforums.com/tutorials/47266-turn-off-peek-desktop-windows-10-a.html
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisablePreviewDesktop" -Type DWord -Value "1"

# Visual effects - Disable "Aero Peek" - https://virtualfeller.com/2015/11/19/windows-10-optimization-part-4-user-interface
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value "0"

# Set the Title And Border Color to black - https://dybbugt.no/2020/1655 - https://winaero.com/blog/enable-dark-title-bars-custom-accent-color-windows-10
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\DWM" -Name "AccentColor" -Type DWord -Value "4292311040"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\DWM" -Name "ColorizationColor" -Type DWord -Value "4292311040"

# Enable the Border and title bar coloring - https://dybbugt.no/2020/1655
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value "1"

# Visual effects - Disable "Save taskbar thumbnail previews" - https://virtualfeller.com/2015/11/19/windows-10-optimization-part-4-user-interface
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Type DWord -Value "0"

# Internet Explorer
# Turn off no protected mode warning - https://www.carlstalhood.com/group-policy-objects-vda-user-settings/#ie
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Internet Explorer\Main" -Name "NoProtectedModeBanner" -Type DWord -Value "1"

# Disable hardware graphics acceleration - http://shawnbass.com/psa-software-gpu-can-reduce-your-virtual-desktop-scalability
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Internet Explorer\Main" -Name "UseSWRender" -Type DWord -Value "1"

# Turn the "Always close all tabs" Warning Message Off - https://www.sevenforums.com/tutorials/205544-internet-explorer-always-close-all-tabs-warning-turn-off.html
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Internet Explorer\TabbedBrowsing" -Name "WarnOnClose" -Type DWord -Value "0"

# Search Engine
# Tracking Protection

# Turn Off "Do you want to close all tabs" in Microsoft Edge - https://www.tenforums.com/tutorials/12757-turn-off-ask-close-all-tabs-microsoft-edge-windows-10-a.html
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main" -Name "AskToCloseAllTabs" -Type DWord "0"

# Fixes for Edge PDF hijack - https://community.spiceworks.com/topic/2030554-permanent-fix-for-win10-edge-browser-pdf-html-hijacking
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -Type DWord -Value "1"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Classes\AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9" -Name "NoStaticDefaultVerb" -Type String
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Classes\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723" -Name "NoStaticDefaultVerb" -Type String
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Classes\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723" -Name "NoOpenWith" -Type String
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Classes\AppX4hxtad77fbk3jkkeerkrm0ze94wjf3s9" -Name "NoOpenWith" -Type String

# Office 365/2016/2019
# Removes the First Things First (EULA) - https://social.technet.microsoft.com/Forums/ie/en-US/d8867a27-894b-44ff-898d-24e0d0c6838a/office-2016-proplus-first-things-first-eula-wont-go-away?forum=Office2016setupdeploy
# https://www.carlstalhood.com/group-policy-objects-vda-user-settings/#office2013
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Policies\Microsoft\Office\16.0\Registration" -Name "AcceptAllEulas" -Type DWord -Value "1"

# Remove the default file types dialog - https://www.blackforce.co.uk/2016/05/11/disable-office-2016-default-file-types-dialog
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\16.0\Common\General" -Name "ShownFileFmtPrompt" -Type DWord -Value "1"

# Sets primary editing language to fr-CA - https://docs.microsoft.com/en-us/deployoffice/office2016/customize-language-setup-and-settings-for-office-2016
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\16.0\common\languageresources" -Name "preferrededitinglanguage" -Type String -Value "fr-CA"

# Remove the "Get and set up Outlook Mobile app on my phone" option from Outlook - https://support.microsoft.com/en-ca/help/4010175/disable-the-get-and-set-up-outlook-mobile-app-on-my-phone-option
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\16.0\Outlook\Options\General" -Name "DisableOutlookMobileHyperlink" -Type DWord -Value "1"

# Enable OneNote page tabs appear on the left - https://social.technet.microsoft.com/Forums/en-US/b5cad42a-83a6-4f19-96ed-70e6a3f964de/onenote-how-to-move-page-window-to-the-left-side?forum=officeitproprevious
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\16.0\onenote\Options\Other" -Name "PageTabsOnLeft" -Type DWord -Value "1"

# Open Visio Diagrams and Drawings in Separate Windows
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\16.0\Visio\Application" -Name "SingleInstanceFileOpen" -Type String -Value "0"

# Disable the Microsoft Office Upload Center notification - https://www.ghacks.net/2018/02/09/how-to-disable-the-microsoft-office-upload-center
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\16.0\Common\FileIO" -Name "DisableNotificationIcon" -Type String -Value "1"

# Disable hardware graphics acceleration - http://shawnbass.com/psa-software-gpu-can-reduce-your-virtual-desktop-scalability
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\16.0\Common\Graphics" -Name "DisableHardwareAcceleration" -Type String -Value "1"

# Disable OneDrive Notifications - https://docs.microsoft.com/en-us/archive/blogs/platforms_lync_cloud/disabling-windows-10-action-center-notifications
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop" -Name "Enabled" -Type DWord -Value "0"

# Set OneDriveSetup Variable
$OneDriveSetup = Get-ItemProperty "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Objetct -ExpandProperty "OneDriveSetup"
$OneDrive = Get-ItemProperty "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" | Select-Objetct -ExpandProperty "OneDrive"

# If Variable returns True, Remove the OneDriveSetup Value
If ($OneDriveSetup) { Remove-ItemProperty -Path "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" }
If ($OneDrive) { Remove-ItemProperty -Path "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" }

# Prevent Outlook from being stuck at lauunch due to Teams meeting addin
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\Outlook\AddIns\TeamsAddin.FastConnect" -Name "Description" -Type String -Value "Microsoft Teams Meeting Add-in for Microsoft Office"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\Outlook\AddIns\TeamsAddin.FastConnect" -Name "LoadBehavior" -Type DWord -Value "3"
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\Microsoft\Office\Outlook\AddIns\TeamsAddin.FastConnect" -Name "FriendlyName" -Type String -Value "Microsoft Teams Meeting Add-in for Microsoft Office"

# Add login script on new user creation
$RunOnceKey = "HKEY_USERS\DefaultHive\Software\Microsoft\Windows\CurrentVersion\RunOnce"
#Set-RegistryKey -Key $RunOnceKey -Name "Outook" -Type String -Value "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE /resetfoldernames /recycle"
$NewUserScript = "\\%DomainName%\NETLOGON\NewUserProfile\Set-NewUserProfile.ps1"
If (-not(Test-Path $RunOnceKey)) {
    Set-RegistryKey -Key $RunOnceKey
}
Set-RegistryKey -Key $RunOnceKey -Name "NewUser" -Type String -Value "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -ExecutionPolicy ByPass -File $NewUserScript"

# Set 7-zip to French
Set-RegistryKey -Key "HKEY_USERS\DefaultHive\Software\7-Zip" -Name "Lang" -Type String -Value "fr"

# Unload Hive
Start-Process -FilePath CMD.EXE -ArgumentList "/C REG.EXE UNLOAD HKU\DefaultHive" -Wait -WindowStyle Hidden | Out-Null

# Cleaup temp files
Remove-Item -Path "$envSystemDrive\Users\Default\*.LOG1" -Force
Remove-Item -Path "$envSystemDrive\Users\Default\*.LOG2" -Force
Remove-Item -Path "$envSystemDrive\Users\Default\*.blf" -Force
Remove-Item -Path "$envSystemDrive\Users\Default\*.regtrans-ms" -Force

# Remove PSDrive HKUDefaultHive
Remove-PSDrive HKUDefaultHive

# Remove Server Manager link
Remove-Item -Path "$envSystemDrive\Users\Default\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Server Manager.lnk" -Force

Write-Log -Message "The default user profile was optimized!" -LogType 'CMTrace' -WriteHost $True