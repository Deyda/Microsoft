$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$functionName = ($MyInvocation.MyCommand.Name).Split(".")[0]

Get-Module FSLogixMigration -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module "$rootPath\..\FSLogixMigration.psd1" -Force

Describe -Tag 'Acceptance' "$functionName Acceptance Test" {
    Context "Test Function $functionName" {

        $vhdxPath = "$($env:TEMP)\test.vhdx"
        $newDrive = (New-VHD -path $vhdxPath -SizeBytes 150MB -Dynamic -LogicalSectorSizeBytes 512 |
            Mount-VHD -Passthru |  `
                get-disk -number { $_.DiskNumber } | `
                Initialize-Disk -PartitionStyle GPT -PassThru | `
                New-Partition -UseMaximumSize -AssignDriveLetter:$False | `
                Format-Volume -Confirm:$false -FileSystem NTFS -force | `
                get-partition | `
                Add-PartitionAccessPath -AssignDriveLetter -PassThru | `
                get-volume).DriveLetter

        Write-Verbose "Dismounting VHD."
        Dismount-VHD $vhdxPath
    
        It "$functionName has the correct Parameters" {
            Get-Command $functionName | Should -HaveParameter ProfilePath -Mandatory
        }

        It "$functionName has to mount .vhdx on as disk and compare drive letter if are the same" {
            $tmpDrive = Mount-UPDProfile -ProfilePath $vhdxPath
            "$($newDrive):\" -eq $tmpDrive.Drive | Should -Be $true
        }
        Dismount-VHD $vhdxPath
        Remove-Item $vhdxPath -Force -Confirm:$false
    }
}