Param
  (
    [switch]$RunOnce = $False
  )
<#
.SYNOPSIS
  Clean up (partial) local profiles that are not in use anymore.
.DESCRIPTION
  This script provides a way to delete local (copies) of user profiles that are not in use anymore. There is an option to exclude specified accounts. Special accounts like SYSTEM are always excluded
.PARAMETER RunOnce
  By default, the script will loop continuously, use this parameter to run it only once
.INPUTS
  None
.OUTPUTS
  Logfile
.NOTES
  Version:        1.0
  Author:         Bart Jacobs - @Cloudsparkle
  Creation Date:  17/04/2020
  Purpose/Change: Remove obsolete local profiles

.EXAMPLE
  None
#>

# Usernames to be excluded
$Exclusions = "P-SVC-ACCOUNT1, P-SVC-ACCOUNT2"
$Exclusions = $Exclusions.tolower()

# Set the output folder for the logfile
$currentDir = Split-Path $MyInvocation.MyCommand.Path
$outputdir = $currentDir

# Set the filename for the logfile
$logfilename = "ProfilesDeleted.txt"

# Path and filename for logfile
$logfile = Join-Path $outputdir $logfilename

# Script loop
while ($true)
{
  # Write-host "Starting scriptloop"
  Try {$profiles = Get-WmiObject -Class Win32_UserProfile}
  Catch
    {
    Write-Warning "Failed to retreive user profiles"
    Exit 1
    }

  ForEach ($profile in $profiles)
  {
  # Retreiving profiledata
  $sid = New-Object System.Security.Principal.SecurityIdentifier($profile.SID)
  $account = $sid.Translate([System.Security.Principal.NTAccount])
  $accountDomain = $account.value.split("\")[0]
  $accountName = $account.value.split("\")[1]
  $profilePath = $profile.LocalPath
  $loaded = $profile.Loaded
  $special = $profile.Special
  $excluded = $false

  # Convert the accountname to lower, to match the exclusions
  $accountname = $accountname.tolower()

  if ($Exclusions.Contains($accountName))
    {
    $excluded = $true
    }

  if (-Not $loaded -and -not $special -and -not $excluded)
    {
    Try
      {
      $profile.Delete()
      # Write-Host "Profile deleted successfully" -ForegroundColor Green
      $logEntry = ((Get-Date -uformat "%D %T") + " - Profile deleted successfully: " + $accountname)
	    $logEntry | Out-File $logFile -Append
      }
    Catch
      {
      Write-Host "Error deleting profile" -ForegroundColor Red
      write-host $accountName -ForegroundColor Red
      $logEntry = ((Get-Date -uformat "%D %T") + " - ERROR Deleting profile: " + $accountname)
	    $logEntry | Out-File $logFile -Append
      }
    }
  }

  if ($RunOnce -eq $True)
  {
  write-host "Running Once, exiting now"
  Exit 0
  }

  #Sleeping 30 seconds before the next run
  Write-Host "Sleeping..."
  start-sleep -s 30
}