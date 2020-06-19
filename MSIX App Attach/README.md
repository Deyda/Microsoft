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
