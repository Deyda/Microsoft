<#
******************************************************************************************************************
Name:               Configure-StorageSense
Author:             Kasper Johansen
Website:            https://virtualwarlock.net            

******************************************************************************************************************
.SYNOPSIS
    This script  configures Storage Sense in Windows Server 2019 on a per-user basis.

.DESCRIPTION
    The current group policies does not work with Windows Server 2019 hence this script.

    The Storage Sense feature does not exist in Windows Server 2016! 
    So even if the script might work with Windows Server 2016, the configuration it creates has no effect. 
    In other words the script has not been tested with Windows Server 2016 as it's pointless.

    Don't use this script with Windows 10. 
    The group policies for Storage Sense works in Windows 10 so there should be no need for this script.

    Change each variable below to reflect the configuration needed or leave it at the "defaults"
    which will enable Storage Sense which runs every 7 days and deletes the contents of the temp
    folder and the contents of the Recycle Bin, Downloads and cloud storage locations (OneDrive) every 14 days.

.VARIABLE EnableStorageSense
    Enables or disables Storage Sense

    0 = Disable
    1 = Enable    

.VARIABLE RunInterval
    Configures the Storage Sense run interval to either every day, every 7 days, every month, or when disk space
    is low

    0 = When Windows decides
    1 = Every Day
    7 = Every Week
    30 = Every Month    

.VARIABLE DeleteTempFiles
    Configures Storage Sense to delete temp files that applications are no longer using

    0 = Disable
    1 = Enable    

.VARIABLE DeleteRecycleBinContent
    Enables or disables the removal of the Recycle Bin content

    0 = Disable
    1 = Enable 
          
.VARIABLE DeleteRecycleBinInterval
    Configures the interval of the removal of the Recycle Bin content to either 1 day, every 14 days, every month
    or every 60 days

    0 = Never 
    1 = 1 day
    14 = 14 days
    30 = 30 days
    60 = 60 days

.VARIABLE DeleteDownloadsContent
    Enables or disables the removal of the Downloads folder content

    0 = Off
    1 = On
      
.VARIABLE DeleteRecycleBinInterval
    Configures the interval of the removal of the Downloads folder content to either 1 day, every 14 days,
    every month or every 60 days

    0 = Never
    1 = 1 day
    14 = 14 days
    30 = 30 days
    60 = 60 days

.VARIABLE DeleteOneDriveContent
    Enables or disables the removal of OneDrive folder content.

    0 = Off
    1 = On
      
.VARIABLE DeleteRecycleBinInterval
    Configures the interval of the removal of the OneDrive folder content to either 1 day, every 14 days,
    every month or every 60 days

    0 = Never
    1 = 1 day
    14 = 14 days
    30 = 30 days
    60 = 60 days

******************************************************************************************************************
#>

# Variables
$EnableStorageSense = 1
$RunInterval = 7
$DeleteTempFiles = 1
$DeleteRecycleBinContent = 1
$DeleteRecycleBinInterval = 14
$DeleteDownloadsContent = 1
$DeleteDownloadsInterval = 14
$DeleteOneDriveContent = 1
$DeleteOneDriveInterval = 14

# Function to create registry keys, create registry values or change existing registry values
function Set-RegistryValue
    {
    param(
        [string]$RegPath,
        [string]$RegName,
        $RegValue,
        [ValidateSet("String","ExpandString","Binary","Dword","MultiString","Qword")]
        [string]$RegType = "String"
        )
            If (!(Test-Path -Path $RegPath))
            {
                Write-Output "Creating the registry key $RegPath"
                New-Item -Path $RegPath -Force | Out-Null
            }
                else
                {
                    $RegPath.Property
                    Write-Output "$RegPath already exist"
                }
                    If ($RegName)
                    {
                    $CheckReg = Get-Item -Path $RegPath

                        If ($CheckReg.GetValue($RegName) -eq $null)
                        {
                            Write-Output "Creating the registry value $RegName in $RegPath"
                            New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType $RegType | Out-Null
                        }
                            else
                            {
                                Write-Output "Modifying the registry value $RegName in $RegPath"
                                Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue | Out-Null
                            }
                    }
    }

# Storage Sense registry location
$StoragePolicyRegKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"

# Enable Storage Sense
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "01" -RegType DWORD -RegValue $EnableStorageSense

# Set 'Run Storage Sense' to specified interval
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "2048" -RegType DWORD -RegValue $RunInterval

# Enable 'Delete temporary files that my apps aren't using'
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "04" -RegType DWORD -RegValue $DeleteTempFiles

# Set 'Delete files in my recycle bin at the specified interval
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "08" -RegType DWORD -RegValue $DeleteRecycleBinContent
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "256" -RegType DWORD -RegValue $DeleteRecycleBinInterval

# Set 'Delete files in my Downloads folder at the specified interval
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "32" -RegType DWORD -RegValue $DeleteDownloadsContent
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "512" -RegType DWORD -RegValue $DeleteDownloadsInterval

# Suppress Storage Sense notifications
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "StoragePoliciesNotified" -RegType DWORD -RegValue 1
Set-RegistryValue -RegPath $StoragePolicyRegKey -RegName "CloudfilePolicyConsent" -RegType DWORD -RegValue 1

# Prerequisite for OneDrive cleanup configuration, get the user SID
$User = New-Object System.Security.Principal.NTAccount($env:userDOMAIN, $env:USERNAME)
$GetSID = $User.Translate([System.Security.Principal.SecurityIdentifier])
$UserSID = $GetSID.Value

# Configure OneDrive cleanup for all OneDrive providers configured
# Get OneDrive providers
$OneDriveProviders = Get-ChildItem -Path HKCU:\Software\SyncEngines\Providers\OneDrive\
ForEach ($ProviderKeys in $OneDriveProviders)
{
    $ProviderKeyString = "OneDrive!"+$UserSID+"!Business1|"+$ProviderKeys.Name.Split("\")[-1]
    $ProviderKeyStringPath = $StoragePolicyRegKey +"\" + $ProviderKeyString

        Set-RegistryValue -RegPath $ProviderKeyStringPath -RegName "02" -RegType DWORD -RegValue $DeleteOneDriveContent
        Set-RegistryValue -RegPath $ProviderKeyStringPath -RegName "128" -RegType DWORD -RegValue $DeleteOneDriveInterval
}