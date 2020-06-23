$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

<#
Fix mock before
Describe -Tag 'Unit', 'Acceptance' "$functionName Unit Test" {
    Context "Unit Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter ProfilePath -Mandatory
            Get-Command $functionName | Should -HaveParameter Target -Mandatory
            Get-Command $functionName | Should -HaveParameter VHD -Not -Mandatory
        }

        Mock Get-Profile {
            [pscustomobject]@{
                ProfilePath = 'C:\Users\jpester'
            }
        }

        Mock Get-ADUser {
            New-Object Microsoft.ActiveDirectory.Management.ADUser Identity -Property @{
                SamAccountName = 'jpester'
                SID            = 'S-1-5-21-3286950516-3440391731-2706545478-1190'
                ObjectGUID     = 'a264c192-b541-417a-8ea1-5c13eec4a284'
            }
        }

        It "$functionName has to gathers profile by ParentPath as parameter and verify UserSID" {
            (New-MigrationObject -ProfilePath "C:\Users\jpester" -Target "t:\test\").UserSID | Should -BeExactly "S-1-5-21-3286950516-3440391731-2706545478-1190"
        }

        It "$functionName has to gathers profile by ParentPath as parameter and verify UserGUID" {
            (New-MigrationObject -ProfilePath "C:\Users\jpester" -Target "t:\test\").UserGUID | Should -BeExactly "a264c192-b541-417a-8ea1-5c13eec4a284"
        }

        $profile = Get-ProfileSource -ProfilePath "C:\Users\jpester" | New-MigrationObject -Target "t:\test\"
        It "$functionName has to gathers profile by ParentPath as pipeline and verify UserSID" {
            $profile.UserSID | Should -BeExactly "S-1-5-21-3286950516-3440391731-2706545478-1190"
        }

        It "$functionName has to gathers profile by ParentPath as pipeline and verify UserGUID" {
            $profile.UserGUID | Should -BeExactly "a264c192-b541-417a-8ea1-5c13eec4a284"
        }
    }
}
#>

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    Context "Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter ProfilePath -Mandatory
            Get-Command $functionName | Should -HaveParameter Target -Mandatory
            Get-Command $functionName | Should -HaveParameter VHD -Not -Mandatory
        }

        $profilesPath = "F:\Roaming Profile$\"
        
        $profiles = Get-ChildItem -Path $profilesPath
        $profilePath = $profiles | select -Last 1 | select -ExpandProperty FullName

        It "$functionName has to gathers profile by ParentPath as parameter" {
            (New-MigrationObject -ProfilePath $profilePath -Target "t:\test\").UserSID | Should -Not -BeExactly "SID Not Found"
            (New-MigrationObject -ProfilePath $profilePath -Target "t:\test\").UserGUID | Should -Not -BeExactly "GUID Not Found"
        }

        It "$functionName has to gathers profile by ParentPath as pipeline" {
            $profile = Get-ProfileSource -ParentPath $profilesPath | select -Last 1 | New-MigrationObject -Target "t:\test\"
            ($profile).UserSID | Should -Not -BeExactly "SID Not Found"
            ($profile).UserGUID | Should -Not -BeExactly "GUID Not Found"
        }
    }
}