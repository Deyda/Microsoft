    <#
    .SYNOPSIS
        This function takes an input UserSID and Drive, converting data to regitry format, and creates an file .reg on specify target location.

    .DESCRIPTION
        This function takes direct input from XXX-XXXXXXXXX, using the UserSID as SID and Drive 
        part of .reg file path for save. It then save a created .reg file to specify location.
    
    .PARAMETER UserSID
        This parameter can be piped into this function if it has the Property Name UserSID. Otherwise, a SID can be specified.

    .PARAMETER Drive
        The Target parameter can be an object of path, or a single specified path for save .reg file.
    
    .EXAMPLE
        New-ProfileReg -UserSID "S-1-5-21-1180699209-877415012-3182924384-1004" -Drive "E:\"
 
        The example above create and save .reg file for FSLogix profile container for AD user attached to SID S-1-5-21-1180699209-877415012-3182924384-1004 in location "E:\Profile\AppData\local\FSLogix\ProfileData.reg".

    .NOTES
        Author: Jakub Podoba
        Last Edit: 06/15/2019
        
    #>
    Function New-ProfileReg {
        
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string]$UserSID,

        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string]$Drive
    )
    
    Begin {
        $sidToHex = ''
    }
    
    Process {
        if ($null -ne $UserSID) {
            try {
                Write-Output "Converting user SID: $UserSID, for SAM" 4>&1 | Write-Log -LogPath $LogPath
                $UserSAM = (Get-ADUser $UserSID -Properties samaccountname).samaccountname
                Write-Output "SID converted to SAM: $UserSAM" 4>&1 | Write-Log -LogPath $LogPath

                Write-Output "Searching GUID for user $UserSAM" 4>&1 | Write-Log -LogPath $LogPath
                $UserGUID = (Get-ADUser $UserSAM).objectguid
                Write-Output "GUID found: $UserGUID" 4>&1 | Write-Log -LogPath $LogPath
            }
            catch {
                Write-Error "Unable to find UserSAM" 2>&1 | Write-Log -LogPath $LogPath
            }

            Write-Output "Converting user SID: $UserSID, for hex format" 4>&1 | Write-Log -LogPath $LogPath
            $UserSID.ToCharArray() | ForEach-Object { $sidToHex += ("{0:x}," -f [int]$_) }
            if ($sidToHex.Substring($sidToHex.Length - 1) -eq ",") {
                $UserSIDHex = $sidToHex.Substring(0, $sidToHex.Length - 1)
            }
            else {
                $UserSIDHex = $sidToHex
            }
            Write-Output "SID converted to HEX format: $UserSIDHex" 4>&1 | Write-Log -LogPath $LogPath
        }
        else {
            Write-Error 'Variable $UserSAM is empty' 2>&1 | Write-Log -LogPath $LogPath
        }

        if ($null -ne $Drive) {
            Write-Output "Concatanating path for .reg file" 4>&1 | Write-Log -LogPath $LogPath
        
            <#
            if ($Drive.Substring($Drive.Length - 1) -eq "\") {
                $Drive = $Drive.Substring(0, $Drive.Length - 1)
            }
            #>
            
            $RegFilePath = "$Drive`Profile\AppData\local\FSLogix\ProfileData.reg"
            Write-Output "Path for .reg file: $RegFilePath" 4>&1 | Write-Log -LogPath $LogPath
        }
        else {
            Write-Error 'Variable $RegFilePath is empty' 2>&1 | Write-Log -LogPath $LogPath
        }

        Write-Output "Creating content for .reg file" 4>&1 | Write-Log -LogPath $LogPath
        if ($null -ne $UserSID -or $null -ne $UserSAM -or $null -ne $RegFilePath) {
            <#
            $RegText = "Windows Registry Editor Version 5.00`r`n`r`n
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID]`r`n
`"ProfileImagePath`"=`"C:\\Users\\$UserSAM`"`r`n
`"FSL_OriginalProfileImagePath`"=`"C:\\Users\\$UserSAM`"`r`n
`"Flags`"=dword:00000000`r`n
`"FullProfile`"=dword:00000001`r`n
`"State`"=dword:00000000`r`n
`"Sid`"=hex:$UserSIDHex`r`n
`"Guid`"=`"{$UserGUID}`"`r`n
`"LocalProfileLoadTimeLow`"=dword:db7b2270`r`n
`"LocalProfileLoadTimeHigh`"=dword:01d51808`r`n
`"ProfileAttemptedProfileDownloadTimeLow`"=dword:00000000`r`n
`"ProfileAttemptedProfileDownloadTimeHigh`"=dword:00000000`r`n
`"ProfileLoadTimeLow`"=dword:00000000`r`n
`"ProfileLoadTimeHigh`"=dword:00000000`r`n
`"RunLogonScriptSync`"=dword:00000000`r`n
`"LocalProfileUnloadTimeLow`"=dword:b28133d7`r`n
`"LocalProfileUnloadTimeHigh`"=dword:01d51978`r`n"
#>

            #$UserPathHex = ("C:\Users\$UserSAM" | Format-Hex | Select-Object -Expand Bytes | ForEach-Object { '{0:x2}' -f $_ }) -join ',00,'
            #[string]$UserPathHex + ",00,00,00"

            <#
            #internet example
            $RegText = "Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID]`r`n
`"ProfileImagePath`"=`"C:\\Users\\$UserPathHex`"`r`n
`"Flags`"=dword:00000000`r`n
`"State`"=dword:00000000`r`n
`"ProfileLoadTimeLow`"=dword:00000000`r`n
`"ProfileLoadTimeHigh`"=dword:00000000`r`n
`"RefCount`"=dword:00000000`r`n
`"RunLogonScriptSync`"=dword:00000001`r`n"
#>

            #internet example from James at 20/06/2019
            $RegText = "Windows Registry Editor Version 5.00`r`n`r`n
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID]`r`n
`"ProfileImagePath`"=`"C:\\Users\\$UserSAM`"`r`n
`"Flags`"=dword:00000000`r`n
`"State`"=dword:00000000`r`n
`"ProfileLoadTimeLow`"=dword:00000000`r`n
`"ProfileLoadTimeHigh`"=dword:00000000`r`n
`"RefCount`"=dword:00000000`r`n
`"RunLogonScriptSync`"=dword:00000000`r`n"


<#roam22 working generated
$RegText = "Windows Registry Editor Version 5.00`r`n`r`n

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1-5-21-3286950516-3440391731-2706545478-1422]`r`n
`"ProfileImagePath`"=hex(2):43,00,3a,00,5c,00,55,00,73,00,65,00,72,00,73,00,5c,\`r`n
  00,72,00,6f,00,61,00,6d,00,32,00,32,00,00,00`r`n
`"FSL_OriginalProfileImagePath`"=`"C:\\Users\\roam22`"`r`n
`"Flags`"=dword:00000000`r`n
`"State`"=dword:00000204`r`n
`"Sid`"=hex:01,05,00,00,00,00,00,05,15,00,00,00,74,e2,ea,c3,33,36,10,cd,46,9b,52,\`r`n
  a1,8e,05,00,00`r`n
`"Guid`"=`"{a9a0a3d8-6df6-4299-8cd6-698d6e536768}`"`r`n
`"ProfileAttemptedProfileDownloadTimeLow`"=dword:00000000`r`n
`"ProfileAttemptedProfileDownloadTimeHigh`"=dword:00000000`r`n
`ProfileLoadTimeLow`"=dword:00000000`r`n
`"ProfileLoadTimeHigh`"=dword:00000000`r`n
`"RefCount`"=dword:00000001" #>


            <#
            #Good user template generated auto 
            $RegText = "Windows Registry Editor Version 5.00`r`n`r`n
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$UserSID]`r`n
`"ProfileImagePath`"=`"hex(2):$UserPathHex`"`r`n
`"FSL_OriginalProfileImagePath`"=`"C:\\Users\\$UserSAM`"`r`n
`"Flags`"=dword:00000000`r`n
`"State`"=dword:00000204`r`n
`"Sid`"=hex:$UserSIDHex`r`n
`"Guid`"=`"{$UserGUID}`"`r`n
`"ProfileAttemptedProfileDownloadTimeLow`"=dword:00000000`r`n
`"ProfileAttemptedProfileDownloadTimeHigh`"=dword:00000000`r`n
`"ProfileLoadTimeLow`"=dword:00000000`r`n
`"ProfileLoadTimeHigh`"=dword:00000000`r`n
`"RefCount`"=dword:00000001`r`n"
#>
            Write-Output "Content for .reg file created" 4>&1 | Write-Log -LogPath $LogPath
            
            Write-Output "Testing path for .reg file" 4>&1 | Write-Log -LogPath $LogPath
            if (!(Test-Path $RegFilePath)) {
                try {
                    New-Item -Path $RegFilePath -ItemType File -Force                    
                }
                catch {
                    Write-Error "Unable to create empty .reg file" 2>&1 | Write-Log -LogPath $LogPath
                }
            }
            else {
                Write-Output "Path for .reg file exists" 4>&1 | Write-Log -LogPath $LogPath
            }

            try {
                Write-Output "Saving generated content for .reg file" 4>&1 | Write-Log -LogPath $LogPath
                $RegText | Out-File $RegFilePath -Encoding ascii -Force
                Write-Output "Generated content for .reg file saved" 4>&1 | Write-Log -LogPath $LogPath
            }
            catch {
                Write-Error "Unable to save generated content for .reg file" 2>&1 | Write-Log -LogPath $LogPath
            }
        }
        else {
            Write-Error 'Variables $UserSID or $UserSAM or $RegFilePath are empty' 2>&1 | Write-Log -LogPath $LogPath
        }
    }
    
    End {
    }
}