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

