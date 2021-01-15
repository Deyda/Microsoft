import-module ActiveDirectory
 
$ODFCShareSource = "\\MyServer\SourceShare"
$ODFCShareDestination = "\\MyServer\DestinationShare"
$UnusedDirMoveLogPath = "C:\UnusedHomeDirMove_log.txt"
$OutPutErrorLogPath = "C:\UnusedHomeDirMove_OutputErrors_log.txt"
 
$folders = Get-ChildItem $ODFCShareSource
 
ForEach ($folder in $folders)
{
    $User = Get-ADUser -LDAPFilter "(sAMAccountName=$($folder.Name.split('_')[1]))"
    If ($User -eq $Null)
    {
        $ODFCDir = $ODFCShareSource+"\"+$folder
        $ODFCShareDestinationDir = $ODFCShareDestination+"\"+$folder
        $ErrorActionPreference = "Stop"
        Try
        {
            Copy-Item -Recurse $ODFCDir $ODFCShareDestinationDir -Force
        }
        Catch
        {
            "--- ERROR" | Out-File $OutPutErrorLogPath -Append
            "$folder" | Out-File $OutPutErrorLogPath -Append
             $_ | Out-File $OutPutErrorLogPath -Append
            "---------" | Out-File $OutPutErrorLogPath -Append
        }
            if ((Test-Path -path $ODFCShareDestinationDir) -eq $True)
            {
                $ErrorActionPreference = "Stop"
                Try
                {
                    cmd.exe /c RD /S /Q $ODFCDir
                        if ((Test-Path -path $HomeDir) -eq $True)
                        {
                            Start-Sleep -s 10
                            cmd.exe /c RD /S /Q $ODFCDir
                        }
                }
                Catch
                {
                    "--- ERROR" | Out-File $OutPutErrorLogPath -Append
                    "$folder" | Out-File $OutPutErrorLogPath -Append
                    $_ | Out-File $OutPutErrorLogPath -Append
                    "---------" | Out-File $OutPutErrorLogPath -Append
                }
            }
         if ((Test-Path -path $ODFCDir) -eq $False)
         {
             if ((Test-Path -path $ODFCShareDestinationDir) -eq $False)
             {
                $LogEntryDate = Get-Date –Format G
                Add-Content -Path $UnusedDirMoveLogPath -Value "--- ERROR"
                Add-Content -Path $UnusedDirMoveLogPath -Value "$LogEntryDate"
                Add-Content -Path $UnusedDirMoveLogPath -Value "$folder"
                Add-Content -Path $UnusedDirMoveLogPath -Value "Folder did not move correctly"
             }
             Else
             {
                $LogEntryDate = Get-Date –Format G
                Add-Content -Path $UnusedDirMoveLogPath -Value "--- OK"
                Add-Content -Path $UnusedDirMoveLogPath -Value "$LogEntryDate"
                Add-Content -Path $UnusedDirMoveLogPath -Value "$folder"
                Add-Content -Path $UnusedDirMoveLogPath -Value "Folder was moved correctly"
             }
         }
         Else
         {
            $LogEntryDate = Get-Date –Format G
            Add-Content -Path $UnusedDirMoveLogPath -Value "--- ERROR"
            Add-Content -Path $UnusedDirMoveLogPath -Value "$LogEntryDate"
            Add-Content -Path $UnusedDirMoveLogPath -Value "$folder"
            Add-Content -Path $UnusedDirMoveLogPath -Value "Folder did not move correctly"
         }
    }
}