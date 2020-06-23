    <#
    .SYNOPSIS
        This function reads a path name and target, parses out the username in path, and creates an object with the needed target destination and username.
    
    .DESCRIPTION
        This Function takes direct input from Get-Profile, and parses a username from the path.
        It also expects a Target destination, assumed to be the FSLogix Profile share.
        It then parses the username out of the source path, finds the SID, (Or vice versa if SID is in path) and outputs a PowerShell Object.
        A Target destination is also calculated in this function, using the expected format for FSLogix.

    .PARAMETER ProfilePath
        The ProfilePath parameter can be an object of paths, or a single specified path.
    
    .PARAMETER Target
        The Target is the destination FSLogix profile share. A new, user-specific target is generated with the parsed information from the path.
    
    .PARAMETER VHD
        By default, a VHDX will be the expected output for a target. If the VHD flag is set, a VHD will be created instead.

    .EXAMPLE
        New-MigrationObject -ProfilePath "C:\users\User1.V2" -Target "\\Server\FSLogixProfiles$"

        ProfilePath : C:\users\User1.V2\
        Username    : User1
        Version     : V2
        UserSID     : S-1-5-21-726503766-34464521-262356478-12241
        UserGUID    : e53615b1-a494-4edf-af94-13557fa591a8
        Target      : \\Server\FSLogixProfiles$\S-1-5-21-726503766-34464521-262356478-12241_User1\Profile_User1.vhdx

        The example above takes a profile path, and generates a username from it, generates a destination based on input target, and creates an object.
        
    .EXAMPLE
        New-MigrationObject -ProfilePath "C:\users\User1.V2" -Target "\\Server\FSLogixProfiles$" -VHD

        ProfilePath : C:\users\User1.V2\
        Username    : User1
        Version     : V2
        UserSID     : S-1-5-21-726503766-34464521-262356478-12241
        UserGUID    : e53615b1-a494-4edf-af94-13557fa591a8
        Target      : \\Server\FSLogixProfiles$\S-1-5-21-726503766-34464521-262356478-12241_User1\Profile_User1.vhd

        The example above does the same thing as Example 1, but with a VHD as the output target.

    .NOTES
        Author: Dom Ruggeri
        Last Edit: 06/27/2019
    
    #>
    Function New-MigrationObject {
        
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True)]
        [string]$ProfilePath,

        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True)]
        [string]$Target,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$VHD
    )
    
    Begin {
        $SIDRegex = "S-\d-\d+-(\d+-){1,14}\d+"
        $VersionRegex = "(?i)(\.V\d)"
        $OutputObject = @()
    }
    
    Process {
        if ($pscmdlet.ShouldProcess($ProfilePath, 'Parsing')){
            
            $Split = (split-path $ProfilePath -Leaf)
            if ($ProfilePath){
                if ($Split -match $VersionRegex){
                    $Username = ($Split -split $VersionRegex)[0]
                    $Version = ($Split).Replace("$Username.","")
                }
                else{
                    $Version = "none"
                }
                
                if ($Split -match $SIDRegex){
                    $UserSID = ($Split | Select-String -Pattern $SIDRegex).matches.groups.value[0]
                    try {
                        $Username = (Get-ADUser -identity $UserSID).SamAccountName
                    }
                    catch {
                        $Username = "Not Found"
                    }
                }
                Else{
                    $Username = ($Split -split $VersionRegex)[0]
                }

                try {
                    $UserSID = (Get-ADUser $Username -Properties SID).SID
                }
                catch {
                    $UserSID = "SID Not Found"
                }
                try {
                    $UserGUID = (Get-ADUser $Username -Properties ObjectGUID).ObjectGUID
                }
                catch {
                    $UserGUID = "GUID Not Found"
                }
                if($VHD){
                    $Extension = ".vhd"
                }
                else{
                    $Extension = ".vhdx"
                }
    
                if (($Target.ToString().ToCharArray() | Select-Object -Last 1) -ne "\"){
                    $Target = $Target+"\"
                }
                if ($UserSID -ne "SID Not Found"){
                    $NewTarget = $Target+$UserSID+"_"+$Username+"\Profile_"+$Username+$Extension
                }
                else {
                    $NewTarget = "Cannot Copy"
                }
            }
            $Item = New-Object system.object
            $Item | Add-Member -Type NoteProperty -Name ProfilePath -Value $ProfilePath
            $Item | Add-Member -Type NoteProperty -Name Username -Value $Username
            $Item | Add-Member -Type NoteProperty -Name Version -Value $Version
            $Item | Add-Member -Type NoteProperty -Name UserSID -Value $UserSID
            $Item | Add-Member -Type NoteProperty -Name UserGUID -Value $UserGUID
            $Item | Add-Member -Type NoteProperty -Name Target -Value $NewTarget
            $OutputObject += $Item
        }
    }
    
    End {
        $OutputObject
    }
}