#requires -version 3.0
<#
    Find SQL accounts with passwords expiring within the specified number of days and optionally send an email containing the information
    Can also be used to send an email alert if the specified SQL server cannot be connected to

    This script is provided as is and with absolutely no warranty such that the author cannot be held responsible for any untoward behaviour or failure of the script.

    @guyrleech 2019
#>

<#
.SYNOPSIS

Query SQL accounts on a SQL server and get those which expire within a given number of days

.PARAMETER sqlserver

The sqlserver\instance to connect to

.PARAMETER accountName

Only SQL accounts matching this regular expression will be returned. If not specified then all accounts found are returned.

.PARAMETER expireWithinDays

Only report accounts which have passwords which are set to expire within this number of days

.PARAMETER username

The SQL username to use to connect to the server rather than using the account that is running the script. Must also specify the password

.PARAMETER password

The password for the -username argument. If the %SQLval1% environment variable is set then its contents are used for the password

.PARAMETER hashedPassword

The hashed password returned from a previous call to the script with -encryptPassword. Will only work on the same machine and for the same user that ran the script to encrypt the password

.PARAMETER mailOnFail

Send an email if the connection to SQL fails

.PARAMETER includeDisabled

Includes accounts which have been disabled and therefore will fail to connect to SQL

.PARAMETER encryptPassword

Encrypt the password passed by the -password option so it can be passed to -hashedPassword or -mailHashedPassword. The encrypted password is specific to the user and machine where they are encrypted.
Pipe through clip.exe or Set-ClipBoard to place in the Windows clipboard

.PARAMETER mailServer

The SMTP mail server to use

.PARAMETER proxyMailServer

If email relaying is only allowed from specific computers, try and remote the Send-Email cmdlet via the server specific via this argument

.PARAMETER noSSL

Do not use SSL to communicate with the mail server

.PARAMETER subject

The subject of the email sent with the expiring account list

.PARAMETER from

The email address to send the email from. Some mail servers must have a valid email address specified

.PARAMETER recipients

A comma separated list of the email addresses to send emails to

.PARAMETER mailUsername

The username to authenticate with at the mail server

.PARAMETER mailPassword

The password for the -mailUsername argument. If the %_MVal12% environment variable is set then its contents are used for the password

.PARAMETER hashedMailPassword

The hashed mail password returned from a previous call to the script with -encryptPassword. Will only work on the same machine and for the same user that ran the script to encrypt the password

.PARAMETER port

The port to use to communicate with the mail server

.PARAMETER nogridview

If not emailing then output the results to the pipeline rather than displaying in a gridview

.PARAMETER logFile

The full path to a log file to append the output of the script to

.EXAMPLE

'.\Microsoft-SQLAccountExpiry.ps1' -sqlServer SQL01\instance01 -recipients guyl@hell.com -mailServer smtp.hell.com -mailOnFail -expireWithinDays 10

This will connect to the specified SQL server instance as the user running the script and email a list of all SQL accounts which expire within the next 10 days to the given recipient.
If the script fails to connect to the SQL server then an email will also be sent containing details of the error.

.EXAMPLE

'.\Microsoft-SQLAccountExpiry.ps1' -sqlServer SQL01\instance01 -accountName bob -includeDisabled

This will connect to the specified SQL server instance as the user running the script and display all SQL accounts with "bob" in the name which either expire within the next 7 days or are disabled

.EXAMPLE

'.\Microsoft-SQLAccountExpiry.ps1' -encryptPassword -password thepassword

This will encrypt the given password and output its encrypted form so that it can be passed as the argument to the -hashedPassword option to avoid having to specify the password on the command line.
The encrypted password will only work for the same user that encrypted it and on the same machine.

.NOTES

Place in a scheduled task where the action should be set to start a program, namely powershell.exe, with the arguments starting with '-file "C:\Scripts\Check SQL account expiry.ps1"' and then having the rest of the required arguments after this.

#>

[CmdletBinding()]

Param
(
    [Parameter(mandatory=$true, ParameterSetName='Query')]
    [string]$sqlServer ,
    [string]$accountName  ,
    [int]$expireWithinDays = 7 ,
    [string]$username ,
    [string]$password ,
    [string]$hashedPassword ,
    [switch]$mailOnFail ,
    [switch]$includeDisabled ,
    [Parameter(mandatory=$true, ParameterSetName='Encrypt')]
    [switch]$encryptPassword ,
    [string]$mailServer ,
    [string]$proxyMailServer = 'localhost' ,
    [switch]$noSSL ,
    [string]$subject = "SQL Accounts with passwords expiring in the next $expireWithinDays days on server $sqlServer" ,
    [string]$from = "$($env:computername)@$($env:userdnsdomain)" ,
    [string[]]$recipients ,
    [string]$mailUsername ,
    [string]$mailPassword ,
    [string]$mailHashedPassword ,
    [int]$port ,
    [switch]$nogridview ,
    [string]$logFile
)

## if dates aren't set, so year 1900, just output a dash
Function Get-RealDate
{
    Param
    (
        [datetime]$date
    )

    if( $date.Year -lt 1980 -and $date.Year -ge 100 )
    {
        '-'
    }
    else
    {
        Get-Date -Date $date -Format G
    }
}

## https://docs.microsoft.com/en-us/sql/t-sql/functions/loginproperty-transact-sql?view=sql-server-2017
$sqlQuery = @'
    SELECT  name AS 'AccountName'
	    ,LOGINPROPERTY(name, 'BadPasswordCount') AS 'BadPasswordCount'
	    ,LOGINPROPERTY(name, 'BadPasswordTime') AS 'BadPasswordTime'
	    ,LOGINPROPERTY(name, 'DaysUntilExpiration') AS 'DaysUntilExpiration'
	    ,LOGINPROPERTY(name, 'DefaultDatabase') AS 'DefaultDatabase'
	    ,LOGINPROPERTY(name, 'DefaultLanguage') AS 'DefaultLanguage'
	    ,LOGINPROPERTY(name, 'HistoryLength') AS 'HistoryLength'
	    ,LOGINPROPERTY(name, 'IsExpired') AS 'IsExpired'
	    ,LOGINPROPERTY(name, 'IsLocked') AS 'IsLocked'
	    ,LOGINPROPERTY(name, 'IsMustChange') AS 'IsMustChange'
	    ,LOGINPROPERTY(name, 'LockoutTime') AS 'LockoutTime'
	    ,LOGINPROPERTY(name, 'PasswordLastSetTime') AS 'PasswordLastSetTime'
	    ,is_expiration_checked, is_disabled , create_date , modify_date
    FROM    sys.sql_logins
    WHERE   is_policy_checked = 1
'@

if( $encryptPassword )
{
    if( ! $PSBoundParameters[ 'password' ] -and ! ( $password = $env:SQLval1 ) )
    {
        Throw 'Must specify the password when encrypting via -password or SQLval1 environment variable'
    }
    
    ConvertTo-SecureString -AsPlainText -String $password -Force | ConvertFrom-SecureString
    Exit 0
}

try
{
    if( ! [string]::IsNullOrEmpty( $logFile ) )
    {
        Start-Transcript -Path $logFile -Append
    }

    [hashtable]$mailParams = $null

    if( ( ! [string]::IsNullOrEmpty( $proxyMailServer )  -or ! [string]::IsNullOrEmpty( $mailServer ) ) -and $recipients.Count )
    {
        if( $recipients -and $recipients.Count -eq 1 -and $recipients[0].IndexOf(',') -ge 0 ) ## fix scheduled task not passing array correctly
        {
            $recipients = $recipients -split ','
        }

        ## Set mail parameters in case we have to send an email that we can't connect to SQL
        $mailParams = @{
                'To' =  $recipients
                'SmtpServer' = $mailServer
                'From' =  $from
                'UseSsl' = ( ! $noSSL ) }
        if( $PSBoundParameters[ 'port' ] )
        {
            $mailParams.Add( 'Port' , $port )
        }
        if( $PSBoundParameters[ 'mailUsername' ] )
        {
            $thePassword = $null
            if( ! $PSBoundParameters[ 'mailPassword' ] )
            {
                if( $PSBoundParameters[ 'mailHashedPassword' ] )
                {
                    Write-Verbose "Using hashed password of length $($mailHashedPassword.Length)"
                    $thePassword = $mailHashedPassword | ConvertTo-SecureString
                }
                elseif( Get-ChildItem -Path env:_MVal12 -ErrorAction SilentlyContinue )
                {
                    $thePassword = ConvertTo-SecureString -AsPlainText -String $env:_MVal12 -Force
                }
            }
            else
            {
                $thePassword = ConvertTo-SecureString -AsPlainText -String $mailPassword -Force
            }
        
            if( $thePassword )
            {
                $mailParams.Add( 'Credential' , ( New-Object System.Management.Automation.PSCredential( $mailUsername , $thePassword )))
            }
            else    
            {
                Write-Error "Must specify mail account password via -mailPassword, -mailHashedPassword or _MVal12 environment variable"
            }
        }
    }

    #region SQL

    $connectionString = "Data Source=$sqlServer;"

    if( ! [string]::IsNullOrEmpty( $username ) )
    {
        ## will only work for SQL auth, Windows must be done via RunAs
        $connectionString += "Integrated Security=no;"
        $connectionString += "uid=$username;"
        if( ! $PSBoundParameters[ 'password' ] )
        {
            if( ! ( $password = $env:SQLval1 ) )
            {
                if( $PSBoundParameters[ 'hashedPassword' ] )
                {
                    $password = [Runtime.interopServices.marshal]::PtrToStringAuto( [Runtime.Interopservices.Marshal]::SecurestringToBstr( ( $hashedPassword|ConvertTo-SecureString ) ) )
                }
                else
                {
                    Throw 'Must specify password'
                }
            }
        }
        $connectionString += "pwd=$password;"
    }
    else
    {
        $connectionString += "Integrated Security=SSPI;"
    }

    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = $connectionString

    try
    {
        $conn.Open()
    }
    catch
    {
        Write-Error "Failed to connect with `"$connectionString`" : $($_.Exception.Message)"
        if( $mailOnFail -and $mailParams )
        {
            [string]$subject = "Failed to connect to $sqlServer as user "
            $subject += $( if( ! [string]::IsNullOrEmpty( $username ) )
            {
                $username
            }
            else
            {
                $env:USERNAME
            })
            $mailParams.Add( 'Subject' , $subject )
            $mailParams.Add( 'Body' , $_.Exception.Message )
            $mailParams.Add( 'BodyAsHtml' , $false )
          
            if( $PSBoundParameters[ 'proxyMailServer' ] )
            {
                Invoke-Command -ComputerName $proxyMailServer -ScriptBlock { [hashtable]$mailParams = $using:mailParams ; Send-MailMessage @mailParams }
            }
            else
            {
                Send-MailMessage @mailParams 
            }
        }

        Exit 1
    }

    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.connection = $conn

    ## Now query the database
    $cmd.CommandText = $sqlQuery

    [datetime]$startTime = Get-Date

    $sqlreader = $cmd.ExecuteReader()

    [datetime]$endTime = Get-Date

    Write-Verbose "Got $($sqlreader.FieldCount) columns from query in $(($endTime - $startTime).TotalSeconds) seconds"

    $datatable = New-Object System.Data.DataTable
    $datatable.Load( $sqlreader )

    $sqlreader.Close()
    $conn.Close()

    #endregion

    Write-Verbose "Retrieved $($datatable.Rows.Count) rows"

    [array]$results = $null

    if( $datatable.Rows -and $datatable.Rows.Count -gt 0 )
    {
        $results = @( $datatable | ForEach-Object `
        {
            $item = $_
            if( ! $accountName -or $item.AccountName -match $accountName )
            {
                if( ( $item.is_expiration_checked -and $item.DaysUntilExpiration -le $expireWithinDays ) `
                    -or $item.IsExpired -or $item.IsLocked -or $item.IsMustChange -or ( $includeDisabled -and $item.is_disabled ) )
                {
                    $item
                }
            }
        })
    }

    if( $results -and $results.Count )
    {   
        if( ( ! [string]::IsNullOrEmpty( $proxyMailServer )  -or ! [string]::IsNullOrEmpty( $mailServer ) ) -and $recipients.Count )
        {
            ## Ok, so it's hard coded! Puts a border on our table
            [string]$style = '<style>BODY{font-family: Arial; font-size: 10pt;}'
            $style += "TABLE{border: 1px solid black; border-collapse: collapse;}"
            $style += "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
            $style += "TD{border: 1px solid black; padding: 5px; }"
            $style += "</style>"

            Write-Verbose "Emailing to $($recipients -join ',') via $mailServer"

            [string]$htmlBody = $results | Sort-Object -Property 'DaysUntilExpiration' | Select-Object -Property 'AccountName',@{n='Expiry Date';e={if( $_.DaysUntilExpiration ) { Get-Date -Date (Get-Date).AddDays( $_.DaysUntilExpiration ) -Format d } elseif( $_.DaysUntilExpiration ) { 'EXPIRED' }}},
                'DaysUntilExpiration','IsExpired','IsLocked','IsMustChange',@{n='Last Lockout Time';e={Get-RealDate -date $_.LockoutTime}},@{n='Password Last Set';e={Get-RealDate -date $_.PasswordLastSetTime}},@{n='Last Bad Password';e={Get-RealDate -date $_.BadPasswordTime}},
                    'is_expiration_checked','is_disabled' | ConvertTo-Html -Head $style

            $mailParams.Add( 'Body' , $htmlBody )
            $mailParams.Add( 'BodyAsHtml' , $true )
            $mailParams.Add( 'Subject' ,  $subject )
         
            if( $PSBoundParameters[ 'proxyMailServer' ] )
            {
                Invoke-Command -ComputerName $proxyMailServer -ScriptBlock { [hashtable]$mailParams = $using:mailParams ; Send-MailMessage @mailParams }
            }
            else
            {
                Send-MailMessage @mailParams 
            }
        }
        elseif( ! $nogridview )
        {
            [array]$selected = @( $results | Out-GridView -PassThru )
            if( $selected -and $selected.Count )
            {
                $selected | Set-Clipboard
            }
        }
        else
        {
            $results
        }
    }
    else
    {
        Write-Warning 'No results returned'
    }
}
catch
{
    Throw $_
}
finally
{
    if( ! [string]::IsNullOrEmpty( $logFile ) )
    {
        Stop-Transcript
    }
}
