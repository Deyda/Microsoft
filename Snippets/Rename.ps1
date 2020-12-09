        Get-ChildItem D:\FslogixCTX\ -Recurse -Filter "CTX*" | ForEach-Object {
        $name = "$($_.name)"
        $parts = $name.split(".")
        $newname = $parts[1]
        $newname = ""+$newname
                    if((Test-Path -path D:\FslogixCTX\$newname))  
                {remove-Item -Path D:\FslogixCTX\$newname            
                }
        Rename-Item -Path D:\FslogixCTX\$name -NewName $newname -force -verbose
        }
