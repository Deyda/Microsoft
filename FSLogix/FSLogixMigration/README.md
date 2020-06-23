# FSLogixMigrationModule

The FSLogix Profile Migration Module is currently private preview. This preview version is provided without a service level agreement, and it's not recommended for production workloads. Certain features might not be supported or might have constrained capabilities.  FDLogix Profile Container may not support all functionality of the formats that are converted. For more information, see Supplemental Terms of Use for Microsoft Azure Previews at https://azure.microsoft.com/en-us/support/legal/preview-supplemental-terms/.

PowerShell Module for Converting UPD/Roaming Profiles to FSLogix Profile Containers
Overview 

The tools will allow the users to perform mass conversions of user profiles from various (specified) types to FSLogix based Profile Containers at scale. This document contains the detailed instructions of tool code base and structure of the code with commands to be executed with detailed examples.  

# Audience  

The target audience of this tool is System administrators to migrate the system profiles with full permissions on the machine to execute the code to migrate the system profiles to FSLogix containers.  

# Prerequisite  

Following are the list of modules to be installed before the execution of the code: 

> ActiveDirectory 

> Hyper-V 

> Pester (version 4.8.1 or above) 

> Administrator must have (at least) read access to ALL files in source profile. Any files that are not visible will not be copied. This script does not change source permissions. 

# Getting started 

Place the FSLogixMigration Folder in a PSModule directory (e.g. C:\Users\<USERNAME>\Documents\WindowsPowerShell\Modules), and import the module with:  

Import-Module FSLogixMigration 

If the module is imported successfully you will see the welcome message.

At the time of import, a check will be done for the following modules: 

> ActiveDirectory (Add-WindowsFeature RSAT-AD-PowerShell)

> Hyper-V (Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All)

> Pester (Install-Module -Name Pester -Force -SkipPublisherCheck)
 

If any of these modules are not found, a warning message will be displayed: 

ActiveDirectory Module not found on this machine. This tool is required to migrate profiles. 

Hyper-V Module not found on this machine. This tool is required to create VHDs. 

Pester Module version 4.8.1 or higher was not found on this machine. This tool is required to run Pester Tests. 

# Running the commands 


The FSLogixMigration Module has two main functions, and a subset of helper functions, that are used within the main functions. 

# Main Functions 

_Convert-RoamingProfile_ – Converts a roaming profile to an FSLogix Profile Container 

_Convert-UPDProfile_ – Converts a user profile disk to an FSLogix Profile Container

_Convert-UPMProfile_ - Converts a UPM Profile to an FSLogix Profile Container.  UPM Conversion has had minimal testing in small environments.

 

# Helper Functions: 

_Get-ProfileSource_ – Takes input for the source type/path 

_New-MigrationObject_ – Creates a PowerShell object, which the script refers to for each migration 

_Mount-UPDProfile_ – Mounts a user profile disk to copy data 

_New-ProfileDisk_ – Creates a VHD or VHDX at the Target location 

_Copy-Profile_ – Runs a Robocopy from source to destination 

_New-ProfileReg_ – Creates an FSLogix Registry .reg file 

_Write-Log_ – Used to write verbose commands and log 

# Syntax 

 

Convert-RoamingProfile 

 

`Convert-RoamingProfile -ParentPath <String> -Target <String> -VHDMaxSizeGB <UInt64> -VHDLogicalSectorSize <String> [-VHD][-IncludeRobocopyDetail] [-LogPath <String>] [-WhatIf] [-Confirm] [<CommonParameters>]`

 

`Convert-RoamingProfile -ProfilePath <String> -Target <String> -VHDMaxSizeGB <UInt64> -VHDLogicalSectorSize <String> [-VHD] [-IncludeRobocopyDetail] [-LogPath <String>] [-WhatIf] [-Confirm] [<CommonParameters>] `

 

`Convert-RoamingProfile -CSV <String> -Target <String> -VHDMaxSizeGB <UInt64> -VHDLogicalSectorSize <String> [-VHD] [-IncludeRobocopyDetail] [-LogPath <String>] [-WhatIf] [-Confirm] [<CommonParameters>] `

 

 Convert-UPDProfile 

 

`Convert-UPDProfile -ParentPath <String> -Target <String> -VHDMaxSizeGB <UInt64> -VHDLogicalSectorSize <String> [-VHD] [-IncludeRobocopyDetail] [-LogPath <String>] [-WhatIf] [-Confirm] [<CommonParameters>] `

 

`Convert-UPDProfile -ProfilePath <String> -Target <String> -VHDMaxSizeGB <UInt64> -VHDLogicalSectorSize <String> [-VHD] [-IncludeRobocopyDetail] [-LogPath <String>] [-WhatIf] [-Confirm] [<CommonParameters>] `

 

`Convert-UPDProfile -CSV <String> -Target <String> -VHDMaxSizeGB <UInt64> -VHDLogicalSectorSize <String> [-VHD] [-IncludeRobocopyDetail] [-LogPath <String>] [-WhatIf] [-Confirm] [<CommonParameters>] `

 

# Examples 

 

`PS C:\>Convert-RoamingProfile -ParentPath "C:\Users\" -Target "\\Server\FSLogixProfiles$" -MaxVHDSize 20 -VHDLogicalSectorSize 512`                                                                                                     

The example above will take inventory of all child-item directories, create a VHDX with a max size of 20GB, Sector Size 512, and copy the source profiles to their respective destinations.          

`PS C:\>Convert-RoamingProfile -ProfilePath "C:\Users\User1" -Target "\\Server\FSLogixProfiles$" -MaxVHDSize 20 -VHDLogicalSectorSize 512 -VHD -IncludeRobocopyDetails -LogPath C:\temp\Log.txt`                


The example above will take the User1 profile, create a VHD with a max size of 20GB, Sector Size 512, and copy the source profiles to their respective destinations. /TEE will be added to Robocopy parameters, and a Log will be generated at C:\Temp\Log.txt 

 

`PS C:\>Convert-UPDProfile -ParentPath "C:\Users\" -Target "\\Server\FSLogixProfiles$" -MaxVHDSize 20 -VHDLogicalSectorSize 512 `

The example above will take inventory of all child-item directories, create a VHDX with a max size of 20GB, Sector Size 512, and copy the source profiles to their respective destinations. 
 

`PS C:\>Convert-UPDProfile -ProfilePath "C:\Users\UserDisk1.vhd" -Target "\\Server\FSLogixProfiles$" -MaxVHDSize 20 -VHDLogicalSectorSize 512 -VHD -IncludeRobocopyDetails -LogPath C:\temp\Log.txt` 

The example above will take the User1 profile, create a VHD with a max size of 20GB, Sector Size 512, and copy the source profiles to their respective destinations. /TEE will be added to Robocopy parameters, and a Log will be generated at C:\Temp\Log.txt 
