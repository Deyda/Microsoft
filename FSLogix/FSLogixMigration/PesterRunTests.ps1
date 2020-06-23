$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Set-Location $rootPath

Import-Module Pester

Invoke-Pester "$rootPath\Tests\FSLogixMigration.Test.ps1"

Invoke-Pester "$rootPath\Tests\Copy-Profile.Test.ps1"

Invoke-Pester "$rootPath\Tests\Get-ProfileSource.Test.ps1"

Invoke-Pester "$rootPath\Tests\Mount-UPDProfile.Test.ps1"

Invoke-Pester "$rootPath\Tests\New-MigrationObject.Test.ps1"

Invoke-Pester "$rootPath\Tests\New-ProfileDisk.Test.ps1"

Invoke-Pester "$rootPath\Tests\New-ProfileReg.Test.ps1"

Invoke-Pester "$rootPath\Tests\Write-Log.Test.ps1"

Invoke-Pester "$rootPath\Tests\Convert-RoamingProfile.Test.ps1" -Tag 'Acceptance'

Invoke-Pester "$rootPath\Tests\Convert-UPDProfile.Test.ps1" -Tag 'Acceptance'

#Invoke-Pester "$rootPath\Tests\Convert-RoamingProfile.Test.ps1" -Tag 'Load'