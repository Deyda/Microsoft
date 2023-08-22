get-childitem $ENV:OneDriveCommercial -Force -File -Recurse -ErrorAction SilentlyContinue |
Where-Object {$_.Attributes -match 'ReparsePoint' -or $_.Attributes -eq '525344' } |
ForEach-Object {
    attrib.exe $_.fullname +U -P /s
}
