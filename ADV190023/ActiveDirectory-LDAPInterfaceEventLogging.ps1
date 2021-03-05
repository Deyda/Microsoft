<#
.SYNOPSIS
This script create a detailed CSV List of the Systems

.DESCRIPTION
This script reads the previously created CSV file if it is not older than 15 minutes. If the file is older, 
the check is automatically repeated and the CSV file is rewritten. The CSV file is read and every domain 
controller that has at least one event (ID 2887 or 3040) is activated for LDAP logging

.NOTES
  Version:          1.0
  Author:           Arne Tiedemann
  Rewrite Author:   Manuel Winkel <www.deyda.net>
  Creation Date:    2020-03-04
  Purpose/Change:   Update for Event ID 3040
#>
Param(
    $Runtime = 30
)
###########################################################################
# Variables
###########################################################################
$OU = (Get-ADDomain).DomainControllersContainer
$DCs = Get-ADComputer -Filter * -SearchBase $OU

# Runtime in Minutes
$Hours = 24

# Create an Array to hold our returnedvValues
$InsecureLDAPCount = @()
$PathLDAPCount = ('{0}\Documents\InsecureLDAPCount.csv' -f $env:USERPROFILE)
###########################################################################
# Functions
###########################################################################

###########################################################################
# Script
###########################################################################
# CleanUp the Environment
$null = Get-ChildItem -Path ~\Documents\InsecureLDAPBinds*.csv | Remove-Item -Force

#check if Enumeration File is new
if ((Test-Path -Path $PathLDAPCount -ErrorAction SilentlyContinue) -and
    (Get-Item -Path $PathLDAPCount).LastWriteTime -gt (Get-Date).AddMinutes(-15)) {
        Write-Warning 'Skip enumerating Domain Controller Events, file is not older than 15 Minutes!'
        $InsecureLDAPCount = Import-Csv -Path $PathLDAPCount
} else {
    # Getting Events from all DCs
    foreach($DC in $DCs.Name) {
        # Define the result as true
        $Result = $true

        if (Test-Connection -Count 1 -ComputerName $DC -ErrorAction SilentlyContinue) {
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
                } catch {
                    Write-Warning $_.Exception.Message
                }
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
                } catch {
                    Write-Warning $_.Exception.Message
                }
            }
        }
    }

    # Dump it all out to a CSV.
    if($InsecureLDAPCount.Count -gt 0) {
        $InsecureLDAPCount | Export-CSV -NoTypeInformation -Path $PathLDAPCount
    }
}
#Scriptblock for getting insecure LDAP Binds
$ScriptBlockLogging = {
    # Get Size of Directory Service Log
    $SizeCurrent = (Get-ItemProperty -Path HKLM:"SYSTEM\CurrentControlSet\Services\EventLog\Directory Service").MaxSize
    # Set Directory Event Log max Size 3GB
    Set-ItemProperty -Path HKLM:"SYSTEM\CurrentControlSet\Services\EventLog\Directory Service" -Name 'MaxSize' -Type DWord -Value '3221225472'
    # Enable Logging of LDAP Events
    Set-ItemProperty -Path HKLM:"SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics" -Name '16 LDAP Interface Events' -Value 2 -Force

    Write-Host " Minutes: "  -NoNewline
    1..$Using:Runtime | ForEach-Object {
        Start-Sleep -Seconds 60
        Write-Host "$($_)," -NoNewline
    }

     # Create an Array to hold our returnedvValues
     $InsecureLDAPBinds = @()

     # Grab the appropriate event entries
     $Events = Get-WinEvent -ComputerName $env:COMPUTERNAME -FilterHashtable @{Logname='Directory Service';Id=2889; StartTime=(Get-Date).AddHours(-$Using:Hours)} -ErrorAction SilentlyContinue

     if ($Events.Count -gt 0) {

         # Loop through each event and output the
         ForEach ($Event in $Events) {
             $eventXML = [xml]$Event.ToXml()

             # Build Our Values
             $Client = ($eventXML.event.EventData.Data[0])
             $IPAddress = $Client.SubString(0,$Client.LastIndexOf(":")) #Accomodates for IPV6 Addresses
             $Port = $Client.SubString($Client.LastIndexOf(":")+1) #Accomodates for IPV6 Addresses
             $User = $eventXML.event.EventData.Data[1]
             Switch ($eventXML.event.EventData.Data[2])
                 {
                    0 {$BindType = "Unsigned"}
                    1 {$BindType = "Simple"}
                 }

            # Add new line to Arraylist
            $InsecureLDAPBinds += [pscustomobject]@{
                DomainController = $env:COMPUTERNAME
                IPAddress = $IPAddress
                Port = $Port
                User = $User
                BindType = $BindType
            }
         }
     }

    # Set Directory Service Log to the old MaxSize Value
    try {
        Set-ItemProperty -Path HKLM:"SYSTEM\CurrentControlSet\Services\EventLog\Directory Service" -Name 'MaxSize' -Type DWord -Value $SizeCurrent -ErrorAction Stop
    } catch {
        Set-ItemProperty -Path HKLM:"SYSTEM\CurrentControlSet\Services\EventLog\Directory Service" -Name 'MaxSize' -Type DWord -Value 1024 -ErrorAction Stop
    }

    # Disable LDAP Logging
    Set-ItemProperty -Path HKLM:"SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics" -Name '16 LDAP Interface Events' -Value 0 -Force

     Write-Host ' Events found: ' -NoNewline
     Write-Host $InsecureLDAPBinds.Count -ForegroundColor Green -NoNewline

     # Dump it all out to a CSV.
     if($InsecureLDAPBinds.Count -gt 0) {
         $InsecureLDAPBinds | Export-CSV -NoTypeInformation C:\Windows\Temp\InsecureLDAPBinds.csv
     }

     # Done
     Write-Host " Done.. " -ForegroundColor Green

}

# Activate LDAP Logging on every DC in the Domain and let it run for 30 minutes
foreach($DC in $InsecureLDAPCount | Where-Object { $_.Count -gt 0 }) {
    if (Test-Connection -Count 1 -ComputerName $DC.DomainController -ErrorAction SilentlyContinue) {
        # Test if Machine is avalable
        try {
            $null = Test-WSMan -ComputerName $DC.DomainController -ErrorAction Stop
            Write-Host 'Running on: ' -NoNewline
            Write-Host $DC.DomainController -ForegroundColor Green -NoNewline

            # invoke command on remote DC
            Invoke-Command -ComputerName $DC.DomainController -ScriptBlock $ScriptBlockLogging -ErrorAction Stop

            # Copy file to local drive
            if (Test-Path -Path ('\\{0}\Admin$\Temp\InsecureLDAPBinds.csv' -f $DC.DomainController) -ErrorAction SilentlyContinue) {
                Move-Item -Path ('\\{0}\Admin$\Temp\InsecureLDAPBinds.csv' -f $DC.DomainController) -Destination ('{0}\Documents\InsecureLDAPBinds_{1}.csv' -f $env:USERPROFILE, $DC.DomainController) -Force
            }
        } catch {
            Write-Host ' The machine: ' -NoNewline
            Write-Host $DC.DomainController -ForegroundColor Green -NoNewline
            Write-Host (' {0}' -f $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

# Get all files and and output a summary
$Files = (Get-ChildItem -Path ~\Documents -Filter 'InsecureLDAPBinds_*.csv').Fullname
$LDAPBinds = @()

foreach($File in $Files) {
    $LDAPBinds += Import-Csv -Path $File
}
###########################################################################
# Finally
###########################################################################
if($LDAPBinds.Count -gt 0) {
    # Cleaning Up the workspace
    $LDAPBinds | Group-Object -Property 'DomainController',"IPAddress","User","BindType" | Select-Object Count, Name
    # Export LDAP Binds
    $LDAPBinds | Export-Csv -NoTypeInformation -Encoding UTF8 -Path ~\Documents\InsecureLDAPBinds.csv -Force
}
###########################################################################
# End
###########################################################################
