$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    Context "Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter Drive -Mandatory
            Get-Command $functionName | Should -HaveParameter ProfilePath -Mandatory
            Get-Command $functionName | Should -HaveParameter IncludeRobocopyDetail -Not -Mandatory
        }

        It "$functionName has the correct private functions" {
            "$rootPath\..\Helper Functions\$functionName.ps1" | Should -FileContentMatch "function Copy-WithProgress"
        }

        It "$functionName has to copy and check file" {
            $Path = "$($env:TEMP)\test"
            if (Test-Path -Path "$Path") {
                Remove-Item -Path "$Path" -Force -Recurse -Confirm:$false
            }
            New-Item -Path "$Path\source\test.txt" -ItemType File -Force
            $sourcePath = "$Path\source\"
            $destinationPath = "$Path\"            
            Copy-Profile -Drive $destinationPath -ProfilePath $sourcePath
            "$Path\Profile\test.txt" | Should -Exist
        }
    }
}