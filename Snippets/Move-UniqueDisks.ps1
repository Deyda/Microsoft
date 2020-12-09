$target="D:\FslogixCTX\"
$path="D:\CtxFslogix\*"



Get-ChildItem -recurse $path -include *-SESSION-* -ErrorAction SilentlyContinue | Foreach-Object {
$pathnew = "$($_.directory)"
$path1 = $pathnew+"\*"
$partcount = ([regex]::Matches($path1, "\\" )).count
$parts = $pathnew.split("\")
$destdriss = $parts[$partcount-1]
$destcount = ([regex]::Matches($destdriss, "_" )).count
$partsdest = $destdriss.split("_")
if ($destcount -eq 1){
$destnew = $target+$partsdest[1]+"_"+$partsdest[0]
}
if ($destcount -eq 2){
$destnew = $target+$partsdest[1]+"_"+$partsdest[2]+"_"+$partsdest[0]
}
if ($destcount -eq 3){
$destnew = $target+$partsdest[1]+"_"+$partsdest[2]+"_"+$partsdest[3]+"_"+$partsdest[0]
}
    if(!(Test-Path -path $destnew))  
        {New-Item -ItemType directory -Path $destnew             
        }
move-item -Path $path1 -Destination $destnew -include *-SESSION-* -ErrorAction SilentlyContinue -Verbose
}