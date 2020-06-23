    <#
    .SYNOPSIS
        This function takes an input source, gathers profiles in the source, and creates an object with profiles.
    
    .DESCRIPTION
        This function takes direct input from Convert-RoamingProfile, using the source type and source location,
        to gather a list of profiles. It then outputs a PowerShell object with those profiles.
    
    .PARAMETER SourceType
        Specify Path, ParentPath, or CSV to identify the source type.
    
    .PARAMETER Source
        CSV or File Path to profiles.
    
    .EXAMPLE
        Get-ProfileSource -SourceType ParentPath -Source "C:\Users"
        The example above adds the "C:\Users" path, and gathers all profiles within it.

    .EXAMPLE
        Get-ProfileSource -SourceType Path -Source "C:\Users\username"
        The example above adds the "C:\Users\username" path, and adds the "username" profile.
        
    .EXAMPLE
        Get-ProfileSource -SourceType CSV -Source "C:\temp\pathlist.csv"
        The example above imports a CSV located at C:\temp\pathlist.csv, and adds the paths in the file.
        

    .NOTES
        Author: Dom Ruggeri
        Last Edit: 06/12/2019
    
    #>
    Function Get-ProfileSource {
        
    [CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='ParentPath')]
    Param (

        # parameters as ParentPath','Path','CSV'

        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,ParameterSetName='ParentPath')]
        [string]$ParentPath,
            
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,ParameterSetName='ProfilePath')]
        [string]$ProfilePath,

        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,ParameterSetName='CSV')]
        [string]$CSV
    )
    
    Begin {
        $OutputObject = @()
    }
    
    Process {
        if ($ParentPath) {
            if ($pscmdlet.ShouldProcess($ParentPath, 'Import')){
                $PathList = ((Get-ChildItem $ParentPath).FullName)
                foreach ($Path in $PathList){
                    $Item = New-Object system.object
                    $Item | Add-Member -Type NoteProperty -Name ProfilePath -Value $Path
                    $OutputObject += $Item
                }
            }
        }

        if ($ProfilePath) {
            if ($pscmdlet.ShouldProcess($ProfilePath, 'Import')){
                $Item = New-Object system.object
                $Item | Add-Member -Type NoteProperty -Name ProfilePath -Value ((Get-Item $ProfilePath).FullName)
                $OutputObject += $Item
            }
        }

        if ($CSV) {
            if ($pscmdlet.ShouldProcess($CSV, 'Import')){
                if (!((Import-Csv $CSV).Path)){
                    write-host "No Path header"
                }
                $PathList = (Import-Csv $CSV).Path
                foreach ($Path in $PathList){
                    $Item = New-Object system.object
                    $Item | Add-Member -Type NoteProperty -Name ProfilePath -Value $Path
                    $OutputObject += $Item
                }
            }
        }
    }
    
    End {
        $OutputObject
    }
}