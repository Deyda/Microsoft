<#
        .SYNOPSIS
        Checks Remote System for the Update State

        .DESCRIPTION
        ###

        .PARAMETER Computer
        Remote Computer to be checked

        .PARAMETER List
        List of Remote Computer to be checked (not yet implemented)

        .PARAMETER Export
        Export to path with the computer as name
        
        .PARAMETER PassThru
        Returns an object representing the item with which you are working. By default, this cmdlet does not generate any pipeline output.

        .INPUTS
        You can pipe the computer into the command which is recognised by type, you can also pipe any parameter by name. It will also take the path positionally

        .OUTPUTS
        This script outputs a csv file with the result of the processing.  It will optionally produce a custom object with the same information

        .EXAMPLE
        Microsoft-MissingUpdates.ps1 -Computer ADC01
	    This checks a single a single computer and displays the result in the powershell window

        .EXAMPLE
        Microsoft-MissingUpdates.ps1 -Computer ADC01 -Export c:\
	    This checks a single a single computer and and export the result to C:\ADC01.txt
        
    #>

    [CmdletBinding()]

    Param (
    
        [Parameter(
            Position = 1,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Computer,
    
        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [switch]$PassThru,
    
        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$Export = "$env:TEMP\Microsoft-MissingUpdate $(Get-Date -Format yyyy-MM-dd` HH-mm-ss).csv"
    
    )
    
    
    
        Set-StrictMode -Version Latest
        #Requires -RunAsAdministrator
    
    
    
    $updatesession = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session","$Computer"))
    $UpdateSearcher = $updatesession.CreateUpdateSearcher()
    $searchresult = $updatesearcher.Search("IsInstalled=0") # 0 = NotInstalled | 1 = Installed
    #$searchresult.Updates.Count
    
    $Updates = If ($searchresult.Updates.Count -gt 0) {
                      #Updates are waiting to be installed
                      $count = $searchresult.Updates.Count
                      Write-Output "Found $Count update\s on $computer!"
                      #Cache the count to make the For loop run faster
                      For ($i=0; $i -lt $Count; $i++) {
                                      #Create object holding update
                                      $Update = $searchresult.Updates.Item($i)
                                      [pscustomobject]@{
                                            Title = $Update.Title
                                            KB = $($Update.KBArticleIDs)
                                            SecurityBulletin = $($Update.SecurityBulletinIDs)
                                            MsrcSeverity = $Update.MsrcSeverity
                                            IsDownloaded = $Update.IsDownloaded
                                            Description = $Update.Description
                                            RebootRequired = $Update.RebootRequired
                                            ReleaseDate = $Update.LastDeploymentChangeTime
                                            Categories = ($Update.Categories | Select-Object -ExpandProperty Name)
                                            BundledUpdates = @($Update.BundledUpdates)|ForEach{
                                            [pscustomobject]@{
                                                    Title = $_.Title
                                             }
                                            }
                                      }
                      }
    }
    if ($PassThru) {
    $updates |ft kb,title,msrcseverity,ReleaseDate,IsDownloaded,RebootRequired -autosize
    }
    $Export = $Export.TrimEnd(".txt")
    $Export = "$Export $Computer.txt"
    $updatelist = $updates |ft kb,title,msrcseverity,ReleaseDate,IsDownloaded,RebootRequired
    Out-File -FilePath $Export -Width 256 -InputObject $Updatelist -Force