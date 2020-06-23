$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    Context "Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter LogPath -Not -Mandatory
            Get-Command $functionName | Should -HaveParameter Message -Mandatory
        }
  
        It "$functionName has to log message as an input string parameter" {
            $testPath = "TestDrive:\test.txt"
            $testMessage = "Testing-$functionName"
            Write-Log -LogPath $testPath -Message $testMessage
            $result = Get-Content $testPath
            (-join $result) | Should -BeLike "*$testMessage*"
        }

        It "$functionName has to log message from pipeline" {
            $testPath = "TestDrive:\test.txt"
            Get-Service -Name Bits | Select-Object -ExpandProperty Name *>&1 | Write-Log -LogPath $testPath
            $result = Get-Content $testPath
            (-join $result) | Should -BeLike "*Bits*"
        }
    }
}