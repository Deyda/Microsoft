# MSIX app attach preview 

This repository contains samples to showcase APIs for implementing MSIX app attach. 

Due to this being a preview Microsoft does not offer support for MSIX app attach. All support efforts are community driven. 

Please reference Getting started with MSIX app attach in Windows Virtual Desktop (Preview) document for details on MSIX app attach.

### Additional materials

Please note that the assets below are community supproted and best effort. They do not come with support from Microsoft. 

* [Windows Virtual Desktop on Azure | Released](https://www.youtube.com/watch?v=QLDu6QVohEI) (Microsoft Mechanics, Youtube.com)
* [Windows Virutal Desktop Tech Community](https://techcommunity.microsoft.com/t5/Windows-Virtual-Desktop/bd-p/WindowsVirtualDesktop) 
* [MSIX app attach will fundamentally change working with application landscapes on Windows Virtual Desktop!](https://blogs.msdn.microsoft.com/rds/2015/07/13/azure-resource-manager-template-for-rds-deployment) (blog series) [Freek Berson] 
* [Create an MSIX package from a desktop installer (MSI, EXE or App-V) on a VM](https://docs.microsoft.com/en-us/windows/msix/packaging-tool/create-app-package-msi-vm) (Docs.Microsoft.com)
* [Automatic MSIX App Attach script for WVD](https://blog.itprocloud.de/Automatic-MSIX-app-attach-scripts/) (blog) [Marcel Meurer]

## Get the OS image
- Open the [Windows Insider portal](https://www.microsoft.com/software-download/windowsinsiderpreviewadvanced?wa=wsignin1.0) and sign in.
- Scroll down to the Select edition section and select Windows 10 Insider Preview Enterprise (FAST) – Build 19035 or later.
- Select Confirm, then select the language you wish to use, and then select Confirm again.
- When the download link is generated, select the 64-bit Download and save it to your local hard disk.

## Prepare the VHD Image
After you've created your master VHD image, you must disable automatic updates for MSIX app attach applications. To disable automatic updates, you'll need to run the following commands in an elevated command prompt:
````
rem Disable Store auto update:

reg add HKLM\Software\Policies\Microsoft\WindowsStore /v AutoDownload /t REG_DWORD /d 0 /f
Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Automatic app update" /Disable
Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable

rem Disable Content Delivery auto download apps that they want to promote to users:

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f

reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug /v ContentDeliveryAllowedOverride /t REG_DWORD /d 0x2 /f

rem Disable Windows Update:

sc config wuauserv start=disabled
````

## Generate a VHD or VHDX package for MSIX
Packages are in VHD or VHDX format to optimize performance. MSIX requires VHD or VHDX packages to work properly.
To generate a VHD or VHDX package for MSIX:

- Download the [msixmgr tool](https://aka.ms/msixmgr) and save the .zip folder to a folder within a session host VM.
- Unzip the msixmgr tool .zip folder.
- Put the source MSIX package into the same folder where you unzipped the msixmgr tool.
- Run the following cmdlet in PowerShell to create a VHD:
````
New-VHD -SizeBytes <size>MB -Path c:\temp\<name>.vhd -Dynamic -Confirm:$false
````
- Run the following cmdlet to mount the newly created VHD:
````
$vhdObject = Mount-VHD c:\temp\<name>.vhd -Passthru
````
- Run this cmdlet to initialize the VHD:
````
$disk = Initialize-Disk -Passthru -Number $vhdObject.Number
````
- Run this cmdlet to create a new partition:
````
$partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $disk.Number
````
- Run this cmdlet to format the partition:
````
Format-Volume -FileSystem NTFS -Confirm:$false -DriveLetter $partition.DriveLetter -Force
````
- Create a parent folder on the mounted VHD. This step is mandatory as the MSIX app attach requires a parent folder. You can name the parent folder whatever you like.
### Expand MSIX
After that, you'll need to "expand" the MSIX image by unpacking it. To unpack the MSIX image:
- Open a command prompt as Administrator and navigate to the folder where you downloaded and unzipped the msixmgr tool.
- Run the following cmdlet to unpack the MSIX into the VHD you created and mounted in the previous section.
````
msixmgr.exe -Unpack -packagePath <package>.msix -destination "f:\<name of folder you created earlier>" -applyacls
````
The following message should appear once unpacking is done:
````
Successfully unpacked and applied ACLs for package: <package name>.msix
````
- Navigate to the mounted VHD and open the app folder and confirm package content is present.
- Unmount the VHD.

## Install certificates
If your app uses a certificate that isn't public-trusted or was self-signed, here's how to install it:

- Right-click the package and select Properties.
- In the window that appears, select the Digital signatures tab. There should be only one item in the list on the tab, as shown in the following image. Select that item to highlight the item, then select Details.
- When the digital signature details window appears, select the General tab, then select Install certificate.
- When the installer opens, select local machine as your storage location, then select Next.
- If the installer asks you if you want to allow the app to make changes to your device, select Yes.
- Select Place all certificates in the following store, then select Browse.
- When the select certificate store window appears, select Trusted people, then select OK.
- Select Finish.

## Prepare PowerShell scripts for MSIX app attach
MSIX app attach has four distinct phases that must be performed in the following order:

1. Stage
2. Register
3. Deregister
4. Destage

Each phase creates a PowerShell script. Sample scripts for each phase are available here.

After you've disabled automatic updates, you must enable Hyper-V because you'll be using the Mound-VHD command to stage and and Dismount-VHD to destage.
```
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
````
### Stage the PowerShell script
Before you update the PowerShell scripts, make sure you have the volume GUID of the volume in the VHD. To get the volume GUID:

- Open the network share where the VHD is located inside the VM where you'll run the script.
- Right-click the VHD and select Mount. This will mount the VHD to a drive letter.
- After you mount the VHD, the File Explorer window will open. Capture the parent folder and update the $parentFolder variable
- Open the parent folder. If correctly expanded, you'll see a folder with the same name as the package. Update the $packageName variable to match the name of this folder.
For example, VSCodeUserSetup-x64-1.38.1_1.38.1.0_x64__8wekyb3d8bbwe.
- Open a command prompt and enter mountvol. This command will display a list of volumes and their GUIDs. Copy the GUID of the volume where the drive letter matches the drive you mounted your VHD to in step 2.
For example, in this example output for the mountvol command, if you mounted your VHD to Drive C, you'll want to copy the value above C:\:
````
Possible values for VolumeName along with current mount points are:

\\?\Volume{a12b3456-0000-0000-0000-10000000000}\
*** NO MOUNT POINTS ***

\\?\Volume{c78d9012-0000-0000-0000-20000000000}\
    E:\

\\?\Volume{d34e5678-0000-0000-0000-30000000000}\
    C:\
````
- Update the $volumeGuid variable with the volume GUID you just copied.
- Open an Admin PowerShell prompt and update the following PowerShell script with the variables that apply to your environment.
````
#MSIX app attach staging sample
#region variables
$vhdSrc="<path to vhd>"
$packageName = "<package name>"
$parentFolder = "<package parent folder>"
$parentFolder = "\" + $parentFolder + "\"
$volumeGuid = "<vol guid>"
$msixJunction = "C:\temp\AppAttach\"
#endregion
#region mountvhd
try
{
Mount-Diskimage -ImagePath $vhdSrc -NoDriveLetter -Access ReadOnly
Write-Host ("Mounting of " + $vhdSrc + " was completed!") -BackgroundColor Green
}
catch
{
Write-Host ("Mounting of " + $vhdSrc + " has failed!") -BackgroundColor Red
}
#endregion
#region makelink
$msixDest = "\\?\Volume{" + $volumeGuid + "}\"
if (!(Test-Path $msixJunction))
{
md $msixJunction
}
$msixJunction = $msixJunction + $packageName
cmd.exe /c mklink /j $msixJunction $msixDest
#endregion
#region stage
[Windows.Management.Deployment.PackageManager,Windows.Management.Deployment,ContentType=WindowsRuntime]| Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where {$_.ToString() -eq 'System.Threading.Tasks.Task`1[TResult] AsTask[TResult,TProgress](Windows.Foundation.IAsyncOperationWithProgress`2[TResult,TProgress])'})[0]
$asTaskAsyncOperation = $asTask.MakeGenericMethod([Windows.Management.Deployment.DeploymentResult],[Windows.Management.Deployment.DeploymentProgress])
$packageManager = [Windows.Management.Deployment.PackageManager]::new()
$path = $msixJunction + $parentFolder + $packageName # needed if we do the pbisigned.vhd
$path = ([System.Uri]$path).AbsoluteUri
$asyncOperation = $packageManager.StagePackageAsync($path, $null, "StageInPlace")
$task = $asTaskAsyncOperation.Invoke($null, @($asyncOperation))
$task
#endregion
````
# AppAttach.ps1
For each application, you have to define the following properties:

Property |	Note
--------|-------
vhdSrc | Path to the expanded MSIX app (as vhd)
volumeGuid |	Guid of the vhd
packageName |	Name of the MSIX app attach package
parentFolder |	Root folder name in your vhd
hostPools |	List of host pool names where the package should be applied
userGroups |	List of AD groups: Members get the application linked in their start menu

## Refer this file by a group policy:

- Computer Configuration - Policies - Windows Settings - Scripts - Startup

  - Name: %windir%\System32\WindowsPowerShell\v1.0\powershell.exe

  - Parameter: -ExecutionPolicy Unrestricted -File \ads01\Configuration\WVD\MSIX\AppAttach.ps1 -ConfigFile \\ads01\Configuration\WVD\MSIX\AppAttach.json -Mode VmStart

- Computer Configuration - Policies - Windows Settings - Scripts - Shutdown

  - Name: %windir%\System32\WindowsPowerShell\v1.0\powershell.exe

  - Parameter: -ExecutionPolicy Unrestricted -File \ads01\Configuration\WVD\MSIX\AppAttach.ps1 -ConfigFile \\ads01\Configuration\WVD\MSIX\AppAttach.json -Mode VmShutdown

- User Configuration - Policies - Windows Settings - Scripts - Logon

  - Name: %windir%\System32\WindowsPowerShell\v1.0\powershell.exe

  - Parameter: -ExecutionPolicy Unrestricted -File \ads01\Configuration\WVD\MSIX\AppAttach.ps1 -ConfigFile \ads01\Configuration\WVD\MSIX\AppAttach.json -Mode UserLogon

- User Configuration - Policies - Windows Settings - Scripts - Logoff

  - Name: %windir%\System32\WindowsPowerShell\v1.0\powershell.exe

  - Parameter: -ExecutionPolicy Unrestricted -File \ads01\Configuration\WVD\MSIX\AppAttach.ps1 -ConfigFile \\ads01\Configuration\WVD\MSIX\AppAttach.json -Mode UserLogoff

  - Where \\ads01\Configuration\WVD\MSIX\ is the path to the script and \\ads01\Configuration\WVD\MSIX\AppAttach.json the JSON-configuration file.

- Make sure that the GPO is linked to the computer and enable loopback processing:

- Computer Configuration - Policies - Administrative Templates - System/Group Policy

  - Configure user Group Policy loopback processing mode: Enable - Mode: merge.

## Preparing the golden master for the session hosts
To work with MSIX and have the script do the work you have to prepare your golden image:

- Make sure that you have installed the right version from the insider build

- Double-check that you have NOT prepared your image with the command line commands described in https://docs.microsoft.com/en-us/azure/virtual-desktop/app-attach#prepare-the-vhd-image-for-azure (Disable Store auto-update and so on). It’s only for the VM concerning the converting process.

- Copy the PSTools https://docs.microsoft.com/en-us/sysinternals/downloads/psexec to %Windir%\System32 (you need psexec later)

- Give the service GPSVC the right privileges to mount images:

  - Create a cmd-file with this content:
```
sc privs gpsvc SeManageVolumePrivilege/SeTcbPrivilege/SeTakeOwnershipPrivilege/SeIncreaseQuotaPrivilege/SeAssignPrimaryTokenPrivilege/SeSecurityPrivilege/SeChangeNotifyPrivilege/SeCreatePermanentPrivilege/SeShutdownPrivilege/SeLoadDriverPrivilege/SeRestorePrivilege/SeBackupPrivilege/SeCreatePagefilePrivilege
```
  - Open an administrative cmd and execute:
```
psexec /s cmd
```
  - In this service cmd execute the cmd-file to give GPSVC the right permissions

(This adds the SeManageVolumePrivilege which allows mounting of images)

