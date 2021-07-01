#requires -modules ActiveDirectory
<#
.SYNOPSIS
  Clean out disabled user accounts from a selected AD Group
.DESCRIPTION
  This script provides a GUI to quickly clean an existing AD group from disabled user accounts, optionally recursive
.PARAMETER <Parameter_Name>
    None
.INPUTS
  AD Domain, Source AD group, Recursive
.OUTPUTS
  CSVFile with cleaned out users
.NOTES
  Version:        1.0
  Author:         Bart Jacobs - @Cloudsparkle
  Creation Date:  30/09/2020
  Purpose/Change: Clean AD group of disabled user accounts
 .EXAMPLE
  None
#>

#Custom function to get Recursive AD Group Members
function Get-ADGroupMemberRecursive
{
  [CmdletBinding()]
  param
    (
      [parameter(Mandatory = $true )]
      [string]$Identity,
      [string]$Server
    )

  $RecMembers = Get-ADGroupMember -Identity $Identity -Server $Server

  foreach($RecMember in $RecMembers)
    {
      $RecMember

      if( $RecMember.objectClass -eq 'group' )
      {
        Get-ADGroupMemberRecursive -Identity $RecMember.SID -Server $Server
      }
    }
}

#Making sure we can have those fancy messageboxes working...
Add-Type -AssemblyName PresentationFramework

#Check for running as administrator, if not: exit
Write-Host "Checking for elevated permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
  {
    [System.Windows.MessageBox]::Show("Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again.","Error","OK","Error")
    exit 1
  }
else
  {
    Write-Host "Code is running as administrator — go on executing the script..." -ForegroundColor Green
  }

#Initialize variables
$SelectedDomain = ""
$ADGroup = ""
$Subgroupname = ""
$ToCleanGroup = ""
$CSVFile = "c:\temp\DisabledAccountsCleaned.csv"
$csvContents = @() # Create the empty array that will eventually be the CSV file

#Get the AD DomainName
$ADForestInfo = Get-ADForest
$SelectedDomain = $ADForestInfo.Domains | Out-GridView -Title "Select AD Domain" -OutputMode Single

#Check for a valid DomainName
if ($SelectedDomain -eq $null)
  {
    [System.Windows.MessageBox]::Show("AD Domain not selected","Error","OK","Error")
    exit 1
  }

#Find the right AD Domain Controller
$dc = Get-ADDomainController -DomainName $SelectedDomain -Discover -NextClosestSite

#Get all groups and select the group to clean
$ADGroupList = Get-ADGroup -filter * -Server $SelectedDomain | sort name | select Name
$ADGroup = $ADGroupList | Out-GridView -Title "Select the AD Group that needs cleaning" -OutputMode Single

#Basic checks for selecte groups
if ($ADGroup -eq $null)
  {
    [System.Windows.MessageBox]::Show("Source group not selected","Error","OK","Error")
    exit 1
  }

#Ask for
$DoRecursive = [System.Windows.MessageBox]::Show('Do you want to clean subgroups too?','Run recursive?','YesNo','Question')

#Fetch all members from selecte source group
if ($DoRecursive -eq "Yes")
  {
    #write-host "Recursive Mode"
    $members = Get-ADGroupMemberRecursive -Identity $ADGroup.Name -Server $dc.HostName[0]
  }
Else
  {
    #write-host "Non-Recursive Mode"
    $members = Get-ADGroupMember -Identity $ADGroup.Name -Server $dc.HostName[0]
  }

#Try to clean the selected AD Group
Try
  {
    foreach ($member in $members)
      {
        If ($member.objectClass -eq "group")
          {
            $Subgroupname = $member.SamAccountName
          }
        Else
          {
            $ADUSer = get-aduser -Identity $member
            if ($ADUSer.Enabled -eq $False)
              {
                if ($Subgroupname -eq "")
                  {
                    $ToCleanGroup = $ADGroup.Name
                  }
                Else
                  {
                    $ToCleanGroup = $Subgroupname
                  }

                #uncomment below for rolling output
                #write-host $member.SamAccountName, $ToCleanGroup
                Remove-ADGroupMember -Identity $ToCleanGroup -Members $member.samaccountname -Confirm:$False

                #Get the CSV data ready
                $row = New-Object System.Object # Create an object to append to the array
                $row | Add-Member -MemberType NoteProperty -Name "Account" -Value $member.SamAccountName
                $row | Add-Member -MemberType NoteProperty -Name "GroupName" -Value $ToCleanGroup

                $csvContents += $row # append the new data to the array#
              }
          }
      }

    #Write the CSV output
    $csvContents | Export-CSV -path $CSVFile -NoTypeInformation

    $message = "The AD Group " + $ADGroup.name + " has been cleaned."
    [System.Windows.MessageBox]::Show($message,"Finished","OK","Asterisk")

  }
Catch
  {
    [System.Windows.MessageBox]::Show("AD Group cleaning failed","Error","OK","Error")
    exit 1
  }