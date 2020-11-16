$initialgroup = Get-ADGroupMember -Identity "GroupA" -Recurisve | Select Name

#Create yourself a "bad list" of people that you don't want in your new list. These are people in GroupB, GroupC, GroupD:

$badlist = Get-ADGroupMember -Identity "GroupB" -Recursive | Select Name
$badlist += Get-ADGroupMember -Identity "GroupC" -Recursive | Select Name
$badlist += Get-ADGroupMember -Identity "GroupD" -Recursive| Select Name

#Now you can build your desired list by comparing these two lists, and exclude the names that are in BOTH your GroupA and bad list.

$final_list = @()
ForEach($g in $initialgroup){
    if($badlist.Name -notcontains $g.Name){
        $final_list += $g
    }
}

$final_list | sort Name | Export-CSV -Path "C:\Temp\Users-To-Add.csv"


Import-Csv -Path “C:\Temp\Users-To-Add.csv” | ForEach-Object {Add-ADGroupMember -Identity “Group-Name” -Members $_.’User-Name’}

Add-ADGroupMember -Identity 'New Group' -Members (Get-ADGroupMember -Identity 'Old Group' -Recursive)
