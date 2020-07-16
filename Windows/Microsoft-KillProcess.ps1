<#
.SYNOPSIS
This script kills a process, if this reaches a specific limit and write a log file

.NOTES
  Version:        1.0
  Author:         Manuel Winkel <www.deyda.net>
  Creation Date:  2020-07-16
  Purpose/Change: 
#>

cls
$procname = '<Process NAme>'
$cpu_usage=<CPU Limit>
$logfile = 'c:\temp\1.log'
$proc = Get-Process $procname | select cpu,id
"{0} {1} cpu usage: {2}" -f (Get-Date), $procname, $proc.cpu | Out-File -Append $logfile 

if($proc.cpu -gt $cpu_usage){
"killing process" | Out-File -Append $logfile
kill $proc.id 
}
