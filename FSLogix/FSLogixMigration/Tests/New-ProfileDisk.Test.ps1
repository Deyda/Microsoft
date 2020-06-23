$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    
    Context "Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter Target -Mandatory
            Get-Command $functionName | Should -HaveParameter ProfilePath -Not -Mandatory
            Get-Command $functionName | Should -HaveParameter Username -Mandatory
            Get-Command $functionName | Should -HaveParameter Size -Mandatory
            Get-Command $functionName | Should -HaveParameter SectorSize -Not -Mandatory
        }

        It "$functionName has the correct private functions" {
            "$rootPath\..\Helper Functions\$functionName.ps1" | Should -FileContentMatch "function New-FSLogixVHD"
            "$rootPath\..\Helper Functions\$functionName.ps1" | Should -FileContentMatch "function Mount-FSLogixVHD"
        }

        $profilesPath = "F:\Roaming Profile$\"
        
        $profiles = Get-ChildItem -Path $profilesPath
        $OutputObject = @()
        $profiles | ForEach-Object {
            $profileName = $_.Name
            $largeprofile = [math]::Round(((Get-ChildItem "${profilesPath}${profileName}" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Sum length | Select -ExpandProperty Sum) / 1MB), 2)
            if ($largeprofile -gt 1) {
                $Item = New-Object -TypeName PSObject
                $Item | Add-Member -MemberType NoteProperty -Name Name -Value $profileName
                $Item | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName
                $Item | Add-Member -MemberType NoteProperty -Name "Size(MB)" -Value $largeprofile
                $OutputObject += $Item    
            }
        }
        
        $ProfilePath = $OutputObject | Sort-Object 'Size(MB)' -Descending | select -Last 1
        $VersionRegex = "(?i)(\.V\d)"
        $UserName = ($ProfilePath.Name -split $VersionRegex)[0]
        $ProfilePath = $ProfilePath.FullName
        $vhdxPath = "$($env:TEMP)\test.vhdx"

        $tempFiles = Get-ChildItem $env:temp | Where-Object { $_.Name -like "test*" }
        $tempFiles | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue
     
        It "$functionName has to create profile disk from parameter" {
            $testResult = New-ProfileDisk -Target $vhdxPath -ProfilePath $ProfilePath -Username $UserName -Size 15 -SectorSize 512
            $testResult.Drive | Should -Not -BeNullOrEmpty
            $testResult.Target | Should -BeExactly $vhdxPath
        }
        Dismount-VHD $vhdxPath -ErrorAction SilentlyContinue
        Remove-Item $vhdxPath -Force -Confirm:$false

        $vhdxPath = "$($env:TEMP)\"
        $tests = @{ 'VHD' = $true;
            'VHDX'        = "";
        }

        foreach ($test in $tests.GetEnumerator()) {
            $testName = $test.Name
            $testParameter = $test.Value

            if ($testParameter) {
                $params = @{
                    'VHD' = $true
                }
            }
            else {
                $params = @{ }
            }

            It "$functionName has to create profile disk and test if $testName was created from pipeline" {
                $batchObject = Get-ProfileSource -ProfilePath $ProfilePath | New-MigrationObject -Target "$($env:TEMP)\" @params
                $testResult = New-ProfileDisk -ProfilePath (($batchObject).ProfilePath) -Target (($batchObject).Target) -Username (($batchObject).Username) -Size 15 -SectorSize 512
                $testResult.Drive | Should -Not -BeNullOrEmpty
                $testResult.Target | Should -Not -BeNullOrEmpty
                Dismount-VHD $testResult.Target -ErrorAction SilentlyContinue
                Remove-Item $testResult.Target -Force -Confirm:$false
            }
        }
    }
}