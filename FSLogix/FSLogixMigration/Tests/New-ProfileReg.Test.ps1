$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    Context "Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter UserSID -Mandatory
            Get-Command $functionName | Should -HaveParameter Drive -Mandatory
        }

        $UserSID = Get-ADUser Guest -Properties SID | select -ExpandProperty SID | select -ExpandProperty value

        $targetPath = "$($env:TEMP)\"
        $regFilePath = "${targetPath}Profile\AppData\local\FSLogix\ProfileData.reg"
        
        It "$functionName has to create .reg file from parameter and check is not null or empty" {
            if (Test-Path -Path $regFilePath) {
                Remove-Item $regFilePath -Force -Confirm:$false
            }
            New-ProfileReg -UserSID $UserSID -Drive $targetPath
            Get-Content -Path $regFilePath | Should -Not -BeNullOrEmpty
        }

        It "$functionName has to check if .reg file contains correct User SID" {
            ( -join (Get-Content -Path $regFilePath)) | Should -BeLike "*$UserSID*"
        }

        <#
        It "$functionName has to create .reg file from pipeline" {
            $vhdxPath = "$($env:TEMP)\test.vhdx"
            if (Test-Path -Path $vhdxPath) {
                Remove-Item $vhdxPath -Force -Confirm:$false
            }
            $ProfilePath = Get-ChildItem -Path "C:\Users" -Exclude "Public" | select -Last 1
            $UserName = $ProfilePath.Name
            $ProfilePath = $ProfilePath.FullName
            $testDrive = New-ProfileDisk -Target $vhdxPath -ProfilePath $ProfilePath -Username $UserName -Size 1
            if (Test-Path -Path "${testDrive}Profile\AppData\local\FSLogix\ProfileData.reg") {
                Remove-Item "${testDrive}Profile\AppData\local\FSLogix\ProfileData.reg" -Force -Confirm:$false
            }
            $testDrive | New-ProfileReg -UserSID $UserSID
            Get-Content -Path "${testDrive}Profile\AppData\local\FSLogix\ProfileData.reg" | Should -Not -BeNullOrEmpty
            Get-Content -Path "${testDrive}Profile\AppData\local\FSLogix\ProfileData.reg" | Should -Contain UserSID
        }
        Dismount-VHD $vhdxPath -ErrorAction SilentlyContinue
        if (Test-Path -Path $vhdxPath) {
            Remove-Item $vhdxPath -Force -Confirm:$false
        }
        #>
    }
}