# Hide powershell prompt
Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle,0)

# Set File Associations for Adobe Reader or Adobe Acrobat - https://kolbi.cz/blog/2017/10/25/setuserfta-userchoice-hash-defeated-set-file-type-associations-per-user
Import-Module ActiveDirectory
$User = "$env:UserName"
$AD_Group_AdobeAcrobat = "App-AdobeAcrobat"

If ((Get-ADUser $User -Properties memberof).memberof -like "CN=$AD_Group_AdobeAcrobat*")
    {
        .\SetUserFTA.exe "Adobe Acrobat.txt"
    }
Else
    {
        .\SetUserFTA.exe "Adobe Acrobat Reader.txt"
    }