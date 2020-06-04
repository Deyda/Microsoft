# This script is part of the blog post: https://blog.itprocloud.de/Automatic-MSIX-app-attach-scripts/

param(
	[Parameter(Mandatory)]
	[string] $ConfigFile='AppAttach.json',

	[Parameter(Mandatory)]
	[ValidateNotNullOrEmpty()]
	[ValidateSet('VmStart','VmShutdown','UserLogon','UserLogoff','ShowDemoJson')]
	[string] $Mode
)

#Has to apply on the master image (in system context, with a batch):   sc privs gpsvc SeManageVolumePrivilege/SeTcbPrivilege/SeTakeOwnershipPrivilege/SeIncreaseQuotaPrivilege/SeAssignPrimaryTokenPrivilege/SeSecurityPrivilege/SeChangeNotifyPrivilege/SeCreatePermanentPrivilege/SeShutdownPrivilege/SeLoadDriverPrivilege/SeRestorePrivilege/SeBackupPrivilege/SeCreatePagefilePrivilege

[Windows.Management.Deployment.PackageManager,Windows.Management.Deployment,ContentType=WindowsRuntime] | Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

function LogWriter($message)
{
	write-host((get-date).tostring("u")+" - "+$message)
	if ([System.IO.Directory]::Exists($env:temp)) {write-output((get-date).tostring("u")+" - "+$message) | Out-File (($env:temp)+"\AppAttach-Logging.log") -Append}
}

Class SessionTarget
{
	[String[]]$hostPools
	[String[]]$userGroups
}
Class App
{
    [String]$vhdSrc
	[String]$volumeGuid 
	[String]$packageName
	[String]$parentFolder
	[SessionTarget]$sessionTarget
}
Class Apps
{
    [App[]]$apps
}


if ($mode -eq "ShowDemoJson")
{
	# display a json configuration as template
	$apps = New-Object Apps
	$app1 = New-Object App
	$app2 = New-Object App
	$sessionTarget1= New-Object SessionTarget
	$sessionTarget2= New-Object SessionTarget

	$sessionTarget1.hostPools=@("MSIX-Builder")
	$sessionTarget1.userGroups=@("SW_WVD_All","SW_WVD_NotePadPP")
	$app1.packageName="notepadpp_7.8.1.0_x64__cqx7y23m1rjgy" 
	$app1.vhdSrc="\\ads01\Configuration\WVD\MSIX\NotepadPP.vhd"
	$app1.volumeGuid="9c371391-0000-0000-0000-010000000000"
	$app1.parentFolder = "MSIX-Apps"
	$app1.SessionTarget=$sessionTarget1

	$sessionTarget2.hostPools=@("MSIX-Builder")
	$sessionTarget2.userGroups=@("SW_WVD_All","SW_WVD_FileZilla")
	$app2.packageName="filezilla_3.45.1.0_x64__cqx7y23m1rjgy" 
	$app2.vhdSrc="\\ads01\Configuration\WVD\MSIX\FileZilla.vhd"
	$app2.volumeGuid="2ac99dec-0000-0000-0000-010000000000"
	$app2.parentFolder = "MSIX-Apps"
	$app2.SessionTarget=$sessionTarget2

	$apps.apps+=$app1
	$apps.apps+=$app2

	$apps| Convertto-json -Depth 10
} else 
{
	LogWriter("----------------------------------------------------------------")
    LogWriter("Working with application assignment: "+$mode)
	$n=20
	$localHostPool=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -Name SessionHostPool -ErrorAction Ignore).SessionHostPool 
	$localTenant=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -Name Tenant -ErrorAction Ignore).Tenant 
	while ($n -gt 0 -and $localHostPool -eq $null) {
		# re-try multiple times if session host not registered to WVD backend
		$localHostPool=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -Name SessionHostPool -ErrorAction Ignore).SessionHostPool 
		$localTenant=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -Name Tenant -ErrorAction Ignore).Tenant 
		start-sleep -Seconds 30
		LogWriter("Retrying to get host pool name")
		$n--
	}
	$localHostPool=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -Name SessionHostPool -ErrorAction Ignore).SessionHostPool 
	$localTenant=(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -Name Tenant -ErrorAction Ignore).Tenant 

	if ($localHostPool -eq $null) {
		LogWriter("Cannot get name of host pool - exiting")
		break
	}
	LogWriter("Host pool and tenant detected: ${localTenant}\${localHostPool}")

	# reading configuration file
	$packageStorePath=(Get-AppxDefaultVolume)[0].PackageStorePath
	$msixJunction = ($env:windir)+"\Temp\AppAttach\"

	$user=[System.DirectoryServices.AccountManagement.UserPrincipal]::Current
	$isAdmin=$false
	if ($user -ne $null) {
		$groups=$user.GetGroups()
		$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
		$isAdmin=$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
		LogWriter("User detected: $user - isAdmin: $isAdmin")
	}    

	LogWriter("Running on session host in tenant '${localTenant}' in host pool '${localHostPool}'")
	LogWriter("Try to load configuration file ${ConfigFile}")
	$apps=Get-Content -Raw -Path $ConfigFile | ConvertFrom-Json 
	LogWriter("")
	
	# enummerating
	foreach($app in $apps.apps) {
		LogWriter("Checking package: "+$app.packageName)

		if ($mode -eq "UserLogoff") {
			if ($isAdmin) {
				LogWriter("Skipping de-registration of app while user is an Admin. This avoid removing the package from the whole session host")
			} else {
				LogWriter("Try to un-register app for user (independent from user group and host pool)")
				try {
					$packageName = $app.packageName
					if ((Get-AppxPackage| where {$_.PackageFullName -eq $packageName}).count -gt 0) {
						Remove-AppxPackage -PreserveRoamableApplicationData -Package $packageName
					}
				} catch {
					LogWriter("We got an error: $_")
				}
			}
		}

		if ($mode -eq "VmShutdown") {
			LogWriter("Try to un-mount MSIX package from session host (independent host pool)")
			try {
				$packageName = $app.packageName
				if (Test-Path ($msixJunction+"\"+$packageName)) {
					Remove-AppxPackage -AllUsers -Package $packageName -Confirm:$false
					rmdir ($msixJunction+"\"+$packageName) -Force -Verbose -recurse -Confirm:$false
				}
			} catch {
				LogWriter("We got an error: $_")
			}
		}

		foreach ($hostPool in $app.SessionTarget.hostPools) {
			LogWriter("Checking host pool: "+$hostPool)
			try {
				if ($mode -eq "VmStart" -and $localHostPool -eq $hostPool)
				{
					LogWriter("Try to mount MSIX package to session host")

					$vhdSrc = $app.vhdSrc
					$packageName = $app.packageName
					$parentFolder = $app.parentFolder
					$volumeGuid = $app.volumeGuid
					$parentFolder = "\" + $parentFolder + "\"
					try {
						Mount-Diskimage -ImagePath $vhdSrc -NoDriveLetter -Access ReadOnly  -Confirm:$true
					}
					catch {
						LogWriter("We got an error: Mounting of " + $vhdSrc + " has failed: $_")
					}
					$msixDest = "\\?\Volume{" + $volumeGuid + "}\"
					if (!(Test-Path $msixJunction)) {
						md $msixJunction
					}
					try {
						C:
						cd \
						$linkPath=$msixJunction + $packageName
						cmd.exe /c mklink /J "$linkPath" "$msixDest"
						$asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where { $_.ToString() -eq 'System.Threading.Tasks.Task`1[TResult] AsTask[TResult,TProgress](Windows.Foundation.IAsyncOperationWithProgress`2[TResult,TProgress])'})[0]
						$asTaskAsyncOperation = $asTask.MakeGenericMethod([Windows.Management.Deployment.DeploymentResult], [Windows.Management.Deployment.DeploymentProgress])
						$packageManager = [Windows.Management.Deployment.PackageManager]::new()
						$path = $msixJunction + $packageName + $parentFolder + $packageName
						$path = ([System.Uri]$path).AbsoluteUri
						$asyncOperation = $packageManager.StagePackageAsync($path, $null, "StageInPlace")
						$task = $asTaskAsyncOperation.Invoke($null, @($asyncOperation))
						$task
						## workaround: system registers apps to prevent removing by an administrator logoff -> removed: local admins skips de-registration
						#$path = $packageStorePath + "\" + $packageName + "\AppxManifest.xml"
						#Add-AppxPackage -Path $path -DisableDevelopmentMode -Register -ErrorAction Stop
					} catch {
						LogWriter("We got an error: $_")
					}
				}
			} catch {
				LogWriter("We got an error: $_")
			}
            
			if ($mode -eq "UserLogon" -and $localHostPool -eq $hostPool)
            {
                $isInGroup=$false
                foreach ($userGroup in $app.SessionTarget.userGroups) {
                    if (($groups| where {$_.SamAccountName -eq $userGroup}).count -ne 0) {
                        $isInGroup=$true
                    }
                }
                if ($isInGroup) {
                    LogWriter("Try to register app for user")
					try {
						$packageName = $app.packageName 
						$path = $packageStorePath + "\" + $packageName + "\AppxManifest.xml"
						if (Test-Path $path) {
							Add-AppxPackage -Path $path -DisableDevelopmentMode -Register -ErrorAction Stop
						} else {
							LogWriter("Warning. Path to application doesn't exist!")
						}
					} catch {
						LogWriter("We got an error: $_")
					}
                }
            }
		}
	}	
}
