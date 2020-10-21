$VHDPath = "D:\VHD"
$VHDXFiles = get-childitem $VHDPath -Filter "*.vhd*" -Recurse
if (!(get-module 'hyper-v' -ListAvailable)) { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell }
 
if (!$VHDXFiles) { write-host "No VHD(x) files found. Please change the path to a location that stores VHD(x) files." break }
 
$VHDInfo = foreach ($VHD in $VHDXFiles) {
    $info = get-vhd -path $VHD.FullName
    [PSCustomObject]@{
        MaxSize        = ($info.Size / 1gb)
        CurrentVHDSize = ($info.FileSize / 1gb)
        MinimumSize    = ($info.MinimumSize / 1gb)
        VHDPath        = $info.path
        Type           = $info.vhdtype
        PercentageFull   = ($info.size / $info.FileSize *100 )
    }
}
 
$CombinedSize = (($VHDINFO | Where-Object { $_.type -eq 'Dynamic' }  ).Maxsize | measure-object -sum).sum
$DiskSize = [math]::round((Get-Volume ($VHDPath.Split(':') | Select-Object -First 1)).size / 1gb)
 
if ($CombinedSize -gt $DiskSize) {
    write-host "The combined VHD(x) is greater than the disk: VHD: $($combinedSize)GB - Disk: $($DiskSize)GB"
}