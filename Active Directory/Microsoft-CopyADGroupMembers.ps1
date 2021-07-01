#requires -modules ActiveDirectory
<#
.SYNOPSIS
  Copy AD group members from one AD group to another AD group in the same domain
.DESCRIPTION
  This script provides a GUI to quickly copy AD group members to another existing group in the same domain. Multi-domain forests are supported, the script will query for the AD domain.
.PARAMETER <Parameter_Name>
    None
.INPUTS
  AD Domain, Source AD group, Destination AD Group
.OUTPUTS
  None
.NOTES
  Version:        1.1
  Author:         Bart Jacobs - @Cloudsparkle
  Creation Date:  09/03/2020
  Purpose/Change: Copy AD Group members to another group

.EXAMPLE
  None
#>

#Initialize variables
$SelectedDomain = ""
$SourceGroup = ""
$DestinationGroup = ""

Add-Type -AssemblyName PresentationFramework

#Get the AD DomainName
$ADForestInfo = Get-ADForest
$SelectedDomain = $ADForestInfo.Domains | Out-GridView -Title "Select AD Domain" -OutputMode Single

#Check for a valid DomainName
if ($SelectedDomain -eq $null)
  {
    [System.Windows.MessageBox]::Show("AD Domain not selected","Error","OK","Error")
    exit
  }

#Find the right AD Domain Controller
$dc = Get-ADDomainController -DomainName $SelectedDomain -Discover -NextClosestSite

#Get all groups from selected and select source and destination groups
$ADGroupList = Get-ADGroup -filter * -Server $SelectedDomain | sort name | select Name
$SourceGroup = $ADGroupList | Out-GridView -Title "Select the AD Group Name who's members needs to be copied" -OutputMode Single
$DestinationGroup = $ADGroupList | Out-GridView -Title "Select the AD Group Name that needs to be populated" -OutputMode Single

#Basic checks for selecte groups
if ($SourceGroup -eq $null)
  {
    [System.Windows.MessageBox]::Show("Source group not selected","Error","OK","Error")
    exit 1
  }

if ($DestinationGroup -eq $null)
  {
    [System.Windows.MessageBox]::Show("Destination group not selected","Error","OK","Error")
    exit 1
  }

if ($SourceGroup -eq $DestinationGroup)
  {
    [System.Windows.MessageBox]::Show("Source and Destination groups can not be the same","Error","OK","Error")
    exit 1
  }

#Fetch all members from selecte source group
$member = Get-ADGroupMember -Identity $SourceGroup.Name -Server $dc.HostName[0]

#Try to populate the selected destination group with members
Try
  {
    Add-ADGroupMember -Identity $DestinationGroup.name -Members $member -Server $dc.HostName[0]
    $message = "Members of AD Group " + $SourceGroup.name + " have been copied to AD Group " + $DestinationGroup.Name
    [System.Windows.MessageBox]::Show($message,"Finished","OK","Asterisk")
  }
Catch
  {
    [System.Windows.MessageBox]::Show("AD Group membership copy failed","Error","OK","Error")
  }