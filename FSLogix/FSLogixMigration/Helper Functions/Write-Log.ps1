<#
    .SYNOPSIS
        Creating new logfile in specified location and writes message to specified log file
  
    .DESCRIPTION
        Creates a log file with the path and name specified in the parameters. Checks if log file exists, and if it does deletes it and creates a new one.
        Once created, writes initial logging data
  
    .PARAMETER LogPath
        Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log
  
    .PARAMETER Message
        Mandatory. The string that you want to write to the log
      
    .EXAMPLE
        Write-Log -LogPath "C:\Windows\Temp\Log.txt" -Message 
        Writes a new log message to a new line in the specified log file.

        New-ProfileReg -UserSID 'S-1-5-21-3286950516-3440391731-2706545478-1155' -Drive F:\ -Verbose 4>&1 | Write-Log -LogPath "C:\Windows\Temp\Log.txt"
        Writes all verbose from function to specified log file.

    .NOTES
        Author: Jakub Podoba
        Last Edit: 06/16/2019

    #>
Function Write-Log {
  
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $False)]
        [string]$LogPath,
    
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string[]]$Message
    )
        
    Begin {
        if ($LogPath){
            if (!(Test-Path -Path $LogPath) ) {
                New-Item -Path $LogPath -ItemType File | Out-Null
            
                Add-Content -Path $LogPath -Value "***************************************************************************************************"
                Add-Content -Path $LogPath -Value "$([DateTime]::Now) - Started processing"
                Add-Content -Path $LogPath -Value "***************************************************************************************************"
                Add-Content -Path $LogPath -Value "`n"
            }
        }
    }
        
    Process {
        if ($pscmdlet.ShouldProcess($Name, 'Action')) {
            $Message | ForEach-Object {
                if ($LogPath){
                    Add-Content -Path $LogPath -Value "$([DateTime]::Now) - $_"
                }
                Write-Verbose "$([DateTime]::Now) - $_"
            }
        }
    }
    
    End {
    }
}