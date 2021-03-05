# Collection of Scripts for ADV190023

Here the describes the scripts from [atiedemann](https://github.com/atiedemann) that make it easier for an administrator of an Active Directory domain to find out if their own domain is affected.

The following is deposited for this purpose:

1. **PowerShell Script**: ActiveDirectory-DCLDAPEvents.ps1
2. **GPO**: Group policy for the configuration of the remote management of systems (domain controllers)
3. **PowerShell Script**: Start-LDAP_Interface_Event_Logging.ps1

## Requirements
For best results, run the scripts on a system that meets these requirements.
- Windows Server 2012 R2 or later
- PowerShell module: Active Directory
- PowerShell Remoting must be configured for all domain controllers! (GPO for this is in the GPO folder)
- FireWall configuration for remote access must be configured! This is also configured by the above mentioned GPO.
- Membership in the group Domain Admins

# ActiveDirectory-DCLDAPEvents.ps1
This script checks all domain controllers of the domain via Get-WinEvent and searches for the event with the ID 2887 in the Directory Service Event Log. If this script finds domain controllers where the event occurs, a CSV file is created in the directory ~\Documents and after checking all domain controllers a table is displayed in the shell.

Header of the CSV File:
"DomainController","Count"

# No domain controller or some are not configured for remote management
If you find that some domain controllers are not configured for remote management, you can use the provided Group Policy to configure remote management for all domain controllers.

## Which settings are distributed
The GPO configures the following areas:
- Enable the following services:
    - Windows Management Instrumentation
    - Windows Remote Management
- Windows Firewall: The firewall is not activated, only rules are distributed that allow remote management.
- WinRM Client and Service

### Setup Group Policy
To configure Group Policy, create a new blank policy on the domain controller container and import the policy settings from the directory located in the GPO directory. When you have successfully completed the import and enabled the policy, wait two hours to enable the policies on all domain controllers. If you have multiple sites, policy activation may take longer.

# ActiveDirectory-LDAPInterfaceEventLogging.ps1
## Usage
To execute the script, start an **Administrative** PowerShell and change to the directory where you have saved the script.
The script can be started without parameters!


Run the script in Standard mode
Here the logging for each domain controller is activated for 30 minutes!
<code> .\ActiveDirectory-LDAPInterfaceEventLogging.ps1</code>

Version with specification of the running time in minutes
<code> .\ActiveDirectory-LDAPInterfaceEventLogging.ps1 -Runtime "Minuten"</code>

## Evaluation of simple and unsigned LDAP bindings of the domain controllers
This script reads the previously created CSV file if it is not older than 15 minutes. If the file is older, the check is automatically repeated and the CSV file is rewritten. The CSV file is read and every domain controller that has at least one event (ID 2887 & 3040) is activated for LDAP logging.

### What tasks does the script perform?
- Get-ADDomain queries the container of the domain controller and searches for computer objects in it
- Each domain controller is checked for availability and for event 2887 and 3040 in the Directory Service Event Log
- If the domain controller is reachable and the event was found, it is checked if it is reachable via remote management
- If the domain controller is accessible:
  - The size of the **Directory Service** event log is read and written to a variable
  - The size of the event log is set to 3GB and logging is activated
  - Then the logging is carried out for the specified time
  - If the time has elapsed, the events are read from the event log and written to a CSV file
  - The original size of the event log is reset
  - The local CSV file is then copied to the executing server and renamed
- This procedure is repeated for each domain controller in the CSV file!


The following registry settings are changed:<br />
<code>HKLM:"SYSTEM\CurrentControlSet\Services\EventLog\Directory Service" -Name 'MaxSize' -Type DWord -Value '3221225472'<br />
HKLM:"SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics" -Name '16 LDAP Interface Events'</code>

The CSV files are stored in the Documents folder of the logged-in user, where the header is created as follows: "DomainController","IPAddress","Port","User","BindType"

<code>%UserProfile%\Documents</code>

After all domain controllers have been queried, all local CSV files are read and the sum of all files is written to the file %UserProfile%\Documents\InsecureLDAPBinds.csv. The output in the PowerShell is grouped by domain controller and source IP.
