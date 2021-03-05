<#
.SYNOPSIS
This script checks all domain controller concerning Event ID 2887 & 3040 (LDAP Clear Text/Unsigned)

.DESCRIPTION
This script checks all domain controllers of the domain via Get-WinEvent and searches for the event with the 
ID 2887 in the Directory Service Event Log. If this script finds domain controllers where the event occurs, a 
CSV file is created in the directory ~\Documents and after checking all domain controllers a table is displayed in the shell.

.NOTES
  Version:          1.0
  Author:           Arne Tiedemann
  Rewrite Author:   Manuel Winkel <www.deyda.net>
  Creation Date:    2020-03-04
  Purpose/Change:   Extension by event id 3040 
#>
###########################################################################
# Variables
###########################################################################
$OU = (Get-ADDomain).DomainControllersContainer
$DCs = Get-ADComputer -Filter * -SearchBase $OU

# Create an Array to hold our returnedvValues
$InsecureLDAPCount = @()
###########################################################################
# Functions
###########################################################################

###########################################################################
# Script
###########################################################################
# CleanUp the Environment
$null = Get-ChildItem -Path ~\Documents\InsecureLDAPBinds*.csv | Remove-Item -Force

# Getting Events from all DCs
foreach($DC in $DCs.Name) {
    if (Test-Connection -Count 1 -ComputerName $DC -ErrorAction SilentlyContinue) {
        # Define the result as true
        $Result = $true

        # Test if Machine is avalable
        try {
            $null = Test-WSMan -ComputerName $DC -ErrorAction Stop
        } catch {
            Write-Host 'We are not able to use remote management with these Server: ' -NoNewline
            Write-Host $DC -ForegroundColor Yellow
            $Result = $false
        }

        # Run only if the machine is reachable
        if ($Result -eq $true) {
            try {
                Write-Host 'Getting Events 2887 from DC: ' -NoNewline
                Write-Host $DC -ForegroundColor Green -NoNewline

                # Grab the appropriate event entries
                $Events = Get-WinEvent -ComputerName $DC -FilterHashtable @{Logname='Directory Service';Id=2887; StartTime=(Get-Date).AddHours(-24)} -ErrorAction SilentlyContinue

                if ($Events.Count -gt 0) {

                    # Loop through each event and output the
                    ForEach ($Event in $Events) {
                        $eventXML = [xml]$Event.ToXml()

                        # Build Our Values
                        $Count = ($eventXML.event.EventData.Data[0])
                    }

                    # Add new line to Arraylist
                    $InsecureLDAPCount += [pscustomobject]@{
                        DomainController = $DC
                        Count = $Count
                    }
                }
                Write-Host ' Done...' -ForegroundColor Yellow
            } catch {}
            try {
                Write-Host 'Getting Events 3040 from DC: ' -NoNewline
                Write-Host $DC -ForegroundColor Green -NoNewline

                # Grab the appropriate event entries
                $Events = Get-WinEvent -ComputerName $DC -FilterHashtable @{Logname='Directory Service';Id=3040; StartTime=(Get-Date).AddHours(-24)} -ErrorAction SilentlyContinue


                if ($Events.Count -gt 0) {

                    # Loop through each event and output the
                    ForEach ($Event in $Events) {
                        $eventXML = [xml]$Event.ToXml()

                        # Build Our Values
                        $Count = ($eventXML.event.EventData.Data[0])
                    }

                    # Add new line to Arraylist
                    $InsecureLDAPCount += [pscustomobject]@{
                        DomainController = $DC
                        Count = $Count
                    }
                }
                Write-Host ' Done...' -ForegroundColor Yellow
            } catch {}
        }
    }
}

# Dump it all out to a CSV.
if($InsecureLDAPCount.Count -gt 0) {
    $InsecureLDAPCount | Export-CSV -NoTypeInformation ~\Documents\InsecureLDAPCount.csv
}

###########################################################################
# Finally
###########################################################################
$InsecureLDAPCount | Where-Object { $_.Count -gt 0 } | Format-Table -AutoSize
###########################################################################
# End
###########################################################################
