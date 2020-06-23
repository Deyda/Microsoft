Clear-Host
$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$moduleName = 'FSLogixMigration'

Describe "$moduleName Module Test" {

    Context 'Module Setup' {
        It "has the root module $moduleName.psm1" {
            "$rootPath\..\$moduleName.psm1" | Should Exist
        }

        It "has the a manifest file of $moduleName.psm1" {
            "$rootPath\..\$moduleName.psd1" | Should Exist
            "$rootPath\..\$moduleName.psd1" | Should -FileContentMatch "$moduleName.psm1"
        }

        It "$moduleName folder has Helper Functions" {
            "$rootPath\..\Helper Functions\*.ps1" | Should Exist
        }

        It "$moduleName folder has Main Functions" {
            "$rootPath\..\Main Functions\*.ps1" | Should Exist
        }

        It "$moduleName is valid Powershell code" {
            $psFile = Get-Content -Path "$rootPath\..\$moduleName.psm1" -ErrorAction Stop

            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }

    $functions = (        
        'Copy-Profile',
        'Get-ProfileSource',
        'New-MigrationObject',
        'Mount-UPDProfile',
        'New-ProfileDisk',
        'New-ProfileReg',
        'Write-Log',
        'Convert-RoamingProfile',
        'Convert-UPDProfile'
    )

    foreach ($function in $functions) {

        switch ($function) {
            {
                ($_ -eq 'Copy-Profile') -or
                ($_ -eq 'New-MigrationObject') -or
                ($_ -eq 'Get-ProfileSource') -or
                ($_ -eq 'Mount-UPDProfile') -or
                ($_ -eq 'New-ProfileDisk') -or
                ($_ -eq 'New-ProfileReg') -or
                ($_ -eq 'Write-Log')

            } { $tmpPath = "Helper Functions" }
    
            {
                ($_ -eq 'Convert-RoamingProfile') -or
                ($_ -eq 'Convert-UPDProfile')
            } { $tmpPath = "Main Functions" }
        }

        Context "Test Function $function" {
            It "$function.ps1 should exist" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should Exist
            }

            It "$function.ps1 should have a help block" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch "<#"
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch "#>"
            }

            It "$function.ps1 should have a SYNOPSIS section in the help block" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch ".SYNOPSIS"
            }

            It "$function.ps1 should have a DESCRIPTION section in the help block" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch ".DESCRIPTION"
            }

            It "$function.ps1 should have a PARAMETER section in the help block" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch ".PARAMETER"
            }

            It "$function.ps1 should have a EXAMPLE section in the help block" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch ".EXAMPLE"
            }

            It "$function.ps1 should have a NOTES section in the help block" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch ".NOTES"
            }

            It "$function.ps1 should be an advanced function" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch "function"
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch "CmdletBinding"
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch "Param"
            }

            It "$function.ps1 should support -WhatIf parameter" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch "SupportsShouldProcess"
            }

            It "$function.ps1 should support -Verbose parameter" {
                "$rootPath\..\$tmpPath\$function.ps1" | Should -FileContentMatch "Write-Verbose"
            }

            It "$function.ps1 is valid Powershell code" {
                $psFile = Get-Content -Path "$rootPath\..\$tmpPath\$function.ps1" -ErrorAction Stop
    
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.Count | Should Be 0
            }
        }
    }
}