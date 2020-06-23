$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    Context "Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter ParentPath -Mandatory
            Get-Command $functionName | Should -HaveParameter ProfilePath -Mandatory
            Get-Command $functionName | Should -HaveParameter CSV -Mandatory
        }

        It "$functionName has to gathers all profiles by ParentPath" {
            $Path = "C:\Users"
            Get-ProfileSource -ParentPath $Path | Should -Not -BeNullOrEmpty
        }

        It "$functionName has to fail by not existing ParentPath" {
            $Path = "C:\UsersXXXXXX"
            $errorThrown = $false;
            try {
                Get-ProfileSource -ParentPath $Path -ErrorAction Stop
            }
            catch {
                $errorThrown = $true
            }
            $errorThrown | Should Be $true
        }

        It "$functionName has to gathers profile by ProfilePath" {
            $Path = "C:\Users"
            $profiles = Get-ChildItem -Path $Path | select -Last 1
            Get-ProfileSource -ParentPath $profiles.FullName | Should -Not -BeNullOrEmpty
        }

        It "$functionName has to gathers all profiles by CSV" {
            $Path = "C:\Users"
            $profiles = Get-ChildItem -Path $Path | select @{ Label = "Path"; Expression = { $_.FullName } } | Export-Csv "$($env:TEMP)\test.csv"
            Get-ProfileSource -CSV "$($env:TEMP)\test.csv" | Should -Not -BeNullOrEmpty
        }
    }
}