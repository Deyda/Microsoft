$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

$functions = Get-ChildItem -Path $rootPath -Exclude "*Test.ps1"
$functions | ForEach-Object {
    Get-Module $_.Name | Remove-Module -Force
    Import-Module $_.FullName -Force
}

$targetPath = "E:\FSLogixProfiles$\Test_$functionName"
$profilesUPDPath = "E:\RDSUPDProfiles\"

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    
    Context "Test Function $functionName" {
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter ParentPath -Mandatory
            Get-Command $functionName | Should -HaveParameter ProfilePath -Mandatory
            Get-Command $functionName | Should -HaveParameter CSV -Mandatory
            Get-Command $functionName | Should -HaveParameter Target -Mandatory
            Get-Command $functionName | Should -HaveParameter VHDMaxSizeGB -Mandatory
            Get-Command $functionName | Should -HaveParameter VHDLogicalSectorSize -Mandatory
            Get-Command $functionName | Should -HaveParameter VHD -Not -Mandatory
            Get-Command $functionName | Should -HaveParameter IncludeRobocopyDetail -Not -Mandatory
            Get-Command $functionName | Should -HaveParameter LogPath -Not -Mandatory
        }

        if (!(Test-Path -Path $targetPath)) {
            New-Item -Path $targetPath -ItemType Directory -Force -Confirm:$false
        }

        $logPath = "$targetPath\test-$functionName-$(Get-Date -Format HHmmddMMyy).log"

        $tests = @{ 'VHD' = $true;
            'VHDX'        = "";
        }

        foreach ($test in $tests.GetEnumerator()) {
            $testName = $test.Name
            $testParameter = $test.Value

            $profiles = Get-ChildItem -Path $profilesUPDPath -Exclude "*template*"
            $OutputObject = @()
            $profiles | ForEach-Object {
                $profileName = $_.Name
                $largeprofile = [math]::Round(((Get-ChildItem "${profilesUPDPath}${profileName}" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Sum length | Select -ExpandProperty Sum) / 1MB), 2)
                if ($largeprofile -gt 1) {
                    $Item = New-Object -TypeName PSObject
                    $Item | Add-Member -MemberType NoteProperty -Name Name -Value $profileName
                    $Item | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName
                    $Item | Add-Member -MemberType NoteProperty -Name "Size(MB)" -Value $largeprofile
                    $OutputObject += $Item    
                }
            }
            
            $profilesArray = $OutputObject | Sort-Object 'Size(MB)' -Descending | select -Last 1
            $profilePath = $profilesArray.FullName
            
            if ($testParameter) {
                $params = @{
                    'VHD' = $true
                }
            }
            else {
                $params = @{ }
            }
            $userObject = New-MigrationObject -ProfilePath $profilePath -Target $targetPath @params -ErrorAction SilentlyContinue
            
            Dismount-VHD $userObject.ProfilePath -ErrorAction SilentlyContinue
            Dismount-VHD $userObject.Target -ErrorAction SilentlyContinue
            Split-Path -Path $userObject.Target | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue

            #-Profile ProfilePath
            It "$functionName has to successfully convert UPD profile and test if $testName was created by ProfilePath with $testName file" {
                Convert-UPDProfile -ProfilePath $profilePath -Target $targetPath -VHDMaxSizeGB 200 @params -LogPath $logPath -VHDLogicalSectorSize 512
                Test-Path -Path $userObject.Target | Should Be $true
            }

            It "$functionName has to successfully compare source profile files with a converted profile by ProfilePath with $testName file" {
                $srcDrive = Mount-UPDProfile -ProfilePath $userObject.ProfilePath
                $srcDrivePath = $srcDrive.Drive
                $dstDrive = Mount-UPDProfile -ProfilePath $userObject.Target
                $dstDrivePath = $dstDrive.Drive + "Profile\"
                (Compare-Object -ReferenceObject (Get-ChildItem $srcDrivePath -Recurse -Force) -DifferenceObject (Get-ChildItem $dstDrivePath -Recurse -Force)).count #| should -Be 3
            }

            Dismount-VHD $userObject.ProfilePath -ErrorAction SilentlyContinue
            Dismount-VHD $userObject.Target -ErrorAction SilentlyContinue
            Split-Path -Path $userObject.Target | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue
            
            #-Profile ParentPath
            $multiProfilePath = $profilesUPDPath + "Multiple Profiles"
            $multiProfiles = Get-ChildItem -Path $multiProfilePath

            $tmpOutputObject = @()
            $multiProfiles | ForEach-Object {
                $userObject = New-MigrationObject -ProfilePath $_.FullName -Target $targetPath @params
                $Item = New-Object system.object
                $Item | Add-Member -Type NoteProperty -Name Target -Value $userObject.Target
                $Item | Add-Member -Type NoteProperty -Name ProfilePath -Value $userObject.ProfilePath
                $tmpOutputObject += $Item
            }

            $tmpOutputObject | ForEach-Object {
                if (($_.Target) -ne "Cannot Copy") {
                    Dismount-VHD $_.ProfilePath -ErrorAction SilentlyContinue
                    Dismount-VHD $_.Target -ErrorAction SilentlyContinue
                    Split-Path -Path $_.Target | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue
                }
            }

            It "$functionName has to successfully convert multiple users UPD profiles and test if $testName were created by ParentPath with $testName file" {
                Convert-UPDProfile -ParentPath $multiProfilePath -Target $targetPath -VHDMaxSizeGB 200 @params -LogPath $logPath -VHDLogicalSectorSize 512
                $multiProfiles | ForEach-Object {
                    $userObject = New-MigrationObject -ProfilePath $_.FullName -Target $targetPath @params
                    if (($userObject.Target) -eq "Cannot Copy") {
                        Test-Path -Path $userObject.Target | Should -Be $false                       
                    }
                    else {
                        Test-Path -Path $userObject.Target | Should -Be $true
                    }
                }
            }

            It "$functionName has to successfully compare source profile files with a converted profile by ParentPath with $testName file" {
                $multiProfiles | ForEach-Object {
                    $userObject = New-MigrationObject -ProfilePath $_.FullName -Target $targetPath @params
                    $srcDrive = Mount-UPDProfile -ProfilePath $_.FullName
                    $srcDrivePath = $srcDrive.Drive
                    $dstDrive = Mount-UPDProfile -ProfilePath $userObject.Target
                    $dstDrivePath = $dstDrive.Drive + "Profile\"
                    (Compare-Object -ReferenceObject (Get-ChildItem $srcDrivePath -Recurse -Force) -DifferenceObject (Get-ChildItem $dstDrivePath -Recurse -Force)).count | should -Be 3
                }
            }

            $tmpOutputObject | ForEach-Object {
                if (($_.Target) -ne "Cannot Copy") {
                    Dismount-VHD $_.ProfilePath -ErrorAction SilentlyContinue
                    Dismount-VHD $_.Target -ErrorAction SilentlyContinue
                    Split-Path -Path $_.Target | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue
                }
            }

            #-CSV test
            $CSVPath = "$($env:TEMP)\test.csv"
            if (Test-Path -Path $CSVPath) {
                Remove-Item -Path $CSVPath -Force -Confirm:$false
            }
            $profilesToCSV = $OutputObject | Sort-Object 'Size(MB)' -Descending | select -Last 1
            $profilePath = $profilesToCSV.FullName
            $profilesToCSV | ForEach-Object {
                [pscustomobject]@{ 'Path' = $_.FullName } | Export-Csv -Path $CSVPath -Append -NoTypeInformation
            }
            $userObject = Get-ProfileSource -CSV $CSVPath | New-MigrationObject -Target $targetPath @params

            Dismount-VHD $userObject.ProfilePath -ErrorAction SilentlyContinue
            Dismount-VHD $userObject.Target -ErrorAction SilentlyContinue
            Split-Path -Path $userObject.Target | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue

            It "$functionName has to successfully convert UPD profile and test if $testName was created by CSV with $testName file" {
                Convert-UPDProfile -CSV $CSVPath -Target $targetPath -VHDMaxSizeGB 200 @params -LogPath $logPath -VHDLogicalSectorSize 512
                Test-Path -Path $userObject.Target | Should Be $true
            }

            It "$functionName has to successfully compare source profile files with a converted profile by CSV with $testName file" {
                $srcDrive = Mount-UPDProfile -ProfilePath $userObject.ProfilePath
                $srcDrivePath = $srcDrive.Drive
                $dstDrive = Mount-UPDProfile -ProfilePath $userObject.Target
                $dstDrivePath = $dstDrive.Drive + "Profile\"
                (Compare-Object -ReferenceObject (Get-ChildItem $srcDrivePath -Recurse -Force) -DifferenceObject (Get-ChildItem $dstDrivePath -Recurse -Force)).count | should -Be 3
            }

            Dismount-VHD $userObject.ProfilePath -ErrorAction SilentlyContinue
            Dismount-VHD $userObject.Target -ErrorAction SilentlyContinue
            Split-Path -Path $userObject.Target | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction SilentlyContinue
        }    
    }
}