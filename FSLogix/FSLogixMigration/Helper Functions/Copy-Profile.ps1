    <#
    .SYNOPSIS
        This function mirrors a source directory to a target directory.
    
    .DESCRIPTION
        Copy-Profile uses Robocopy to copy/mirror a source directory to destination directory.
        Robocopy is run with the following arguments: /COPYALL /MIR /NP /NDL /NC /BYTES /NJH /NJS /XJ /R:0 (/TEE if -IncludeRobocopyDetail flag is set)
        A staging file is created and used to get the number of files, then used again to track progress in a write-Progress bar.
        The staging files are removed after use.
        Data is copied to the Destination Drive Specified, in a folder called "Profile" (As expected by FSLogix.)

    .PARAMETER Drive
        Drive is the Drive letter of the mounted VHD Destination Profile. This Drive is assumed to be in "D:\" format.
    
    .PARAMETER ProfilePath
        ProfilePath Parameter is the Source location. The immediate folder structure at this location will be copied to the destination Drive under folder "Profile"

    .PARAMETER IncludeRobocopyDetail
        The IncludeRobocopyDetail parameter will add /TEE to the argument list for the Robocopy function. The /TEE argument will output current file-by-file progress to the screen.
    
    .EXAMPLE
        Copy-Profile -ProfilePath C:\Users\User1 -Drive "D:\"

        The example above will mirror the folder structure of everything in C:\Users\User1 folder to D:\Profile\
        
    .NOTES
        Author: Dom Ruggeri
        Last Edit: 7/23/2019
    
    #>
    Function Copy-Profile {
        
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True)]
        [string]$Drive,
            
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True)]
        [string]$ProfilePath,

        [Parameter()]
        [switch]$IncludeRobocopyDetail

    )
    Begin {
        function Copy-WithProgress {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [string] $Source, 
        
                [Parameter(Mandatory = $true)]
                [string] $Destination,
        
                [int] $Gap = 0,
        
                [int] $ReportGap = 20
            )
            # Define regular expression that will gather number of bytes copied
            $RegexBytes = '(?<=\s+)\d+(?=\s+)'
        
            # Robocopy params
            # COPYALL = Copy all file ownership and permission info
            # MIR = Mirror mode
            # NP  = Don't show progress percentage in log
            # NC  = Don't log file classes (existing, new file, etc.)
            # BYTES = Show file sizes in bytes
            # NJH = Do not display robocopy job header (JH)
            # NJS = Do not display robocopy job summary (JS)
            # TEE = Display log in stdout AND in target log file
            If ($IncludeRobocopyDetail){
                $CommonRobocopyParams = '/COPYALL /MIR /NP /NDL /NC /BYTES /NJH /NJS /XJ /TEE /R:0'
            }
            Else{
                $CommonRobocopyParams = '/COPYALL /MIR /NP /NDL /NC /BYTES /NJH /NJS /XJ /R:0'
            }
            $CommonRobocopyExcludes = "/XD ""$ProfilePath`$RECYCLE.BIN"" ""$ProfilePath`System Volume Information"""
            
            Write-Output 'Analyzing robocopy job ...' 4>&1 | Write-Log -LogPath $LogPath
            $StagingLogPath = '{0}\temp\{1} robocopy staging.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss')
        
            $StagingArgumentList = '"{0}" "{1}" /LOG:"{2}" /L {3} {4}' -f $Source, $Destination, $StagingLogPath, $CommonRobocopyParams, $CommonRobocopyExcludes
            Write-Output ('Staging arguments: {0}' -f $StagingArgumentList) 4>&1 | Write-Log -LogPath $LogPath
            Start-Process -Wait -FilePath robocopy.exe -ArgumentList $StagingArgumentList -NoNewWindow
            # Get the total number of files that will be copied
            $StagingContent = Get-Content -Path $StagingLogPath
            $TotalFileCount = $StagingContent.Count - 1
        
            # Get the total number of bytes to be copied
            [RegEx]::Matches(($StagingContent -join "`n"), $RegexBytes) | ForEach-Object { $BytesTotal = 0; } { $BytesTotal += $_.Value; }
            Write-Output ('Total bytes to be copied: {0}' -f $BytesTotal) 4>&1 | Write-Log -LogPath $LogPath
        
            # Begin the robocopy process
            $RobocopyLogPath = '{0}\temp\{1} robocopy.log' -f $env:windir, (Get-Date -Format 'yyyy-MM-dd HH-mm-ss')
            $ArgumentList = '"{0}" "{1}" /LOG:"{2}" /ipg:{3} {4} {5}' -f $Source, $Destination, $RobocopyLogPath, $Gap, $CommonRobocopyParams, $CommonRobocopyExcludes
            Write-Output ('Beginning the robocopy process with arguments: {0}' -f $ArgumentList) 4>&1 | Write-Log -LogPath $LogPath
            $Robocopy = Start-Process -FilePath robocopy.exe -ArgumentList $ArgumentList -Verbose -PassThru -NoNewWindow
            Start-Sleep -Milliseconds 100
            
            # Progress bar loop
            while (!$Robocopy.HasExited) {
                Start-Sleep -Milliseconds $ReportGap
                $BytesCopied = 0
                $LogContent = Get-Content -Path $RobocopyLogPath
                $BytesCopied = [Regex]::Matches($LogContent, $RegexBytes) | ForEach-Object -Process { $BytesCopied += $_.Value; } -End { $BytesCopied; }
                $CopiedFileCount = $LogContent.Count - 1
                $Percentage = 0
                if ($BytesCopied -gt 0) {
                   $Percentage = (($BytesCopied/$BytesTotal)*100)
                }
                Write-Progress -Activity Robocopy -Status ("Copied {0} of {1} files; Copied {2} of {3} bytes" -f $CopiedFileCount, $TotalFileCount, $BytesCopied, $BytesTotal) -PercentComplete $Percentage
            }

            Remove-Item $StagingLogPath
            Remove-Item $RobocopyLogPath

            [PSCustomObject]@{
                BytesCopied = $BytesCopied
                FilesCopied = $CopiedFileCount
            }
        }
    }
    
    Process {
        if ($pscmdlet.ShouldProcess($Name, 'Action')){
            $Destination = "$Drive"+"Profile\"
            Write-Output "Beginning copy from $ProfilePath to $Destination." 4>&1 | Write-Log -LogPath $LogPath
            Copy-WithProgress -Source "$ProfilePath " -Destination "$Destination "
        }
    }
    
    End {
    }
}