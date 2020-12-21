# ****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# ****************************************************

<#
.SYNOPSIS
Shows a message to user in the notificarion area if FSLogix Office container is almost full.
		
.DESCRIPTION
Gets information about the users FSLogix office container (size and remaining size) and calculates the free space in percent.
		
.EXAMPLE
.FSLogix Office container Size Warning.ps1
	    
.NOTES
This script must be run on a machine where the user is currently logged on.
Should be run as a powershell login script via GPO.
Edit value $PercentFree -le 10 in line 34 to define the free percent.
#>

# Wait 10 sec. till showing the message
Start-Sleep 10

# Get the relevant informations from the FSLogix profile
$FSLOContainerSize = Get-Volume -FileSystemLabel *Profile-$ENV:USERNAME* | Where-Object { $_.DriveType -eq 'Fixed'}

# Execute only if FSLogix profile is available
IF (!($FSLProfileSize -eq $nul))
{
    # Calculate the free space in percent
	$PercentFree = [Math]::round((($FSLOContainerSize.SizeRemaining/$FSLOContainerSize.size) * 100))

	# If free space is less then 10 % show message
	IF ($PercentFree -le 10) {wlrmdr -s 25 -f 2 -t FSLogix Profile -m Attention! Your Office container contingent is almost exhausted. Please inform the IT service!}
}
