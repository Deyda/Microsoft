# Microsoft
## About FSLogix-RemoveContainerData.ps1
FSLogix-RemoveContainerData is used to delete files and folders in a user's FSLogix Profile and Office Container by mounting the Container and pruning files, thus keeping the Container size to a minimum. The script reads an XML file that defines a list of files and folders to remove from the Container. Actions on a target path can be:

Prune - the XML can include a number that defines the age in days for last write that the file must be older than to be deleted. Essentially reducing the size of the folder.
Delete - the target path will be deleted. Where the administrator may want to remove a target path, the Delete action will delete the entire folder.
Trim - where the target path contains sub-folders, this action will remove all sub-folders except for the newest folder.
Supports -WhatIf and -Verbose output and returns a list of files removed from the profile. Add -Verbose will output the total size of files removed from the user profile and processing time at the end of the script. All targets (files / folders) that are deleted, will be logged to a file.

Deleting files from the Container can potentially result in data loss, so testing is advised and the use of -Confirm:$false is required for the script perform a delete.

This script depends on the following PowerShell modules:

ActiveDirectory - Installed as a feature in Windows Server or via RSAT
Hyper-V - Installed as a feature in Windows Server or via RSAT
Fslogix.Powershell.Disk - this module is found here: https://github.com/aaronparker/fslogix/tree/main/Modules/Fslogix.Powershell.Disk

### Usage

.\FSLogix-RemoveContainerData.ps1 -Path \\server\FSLogixContainer -Targets .\targets.xml -Type Profile

#### Running FSLogix-RemoveContainerData.ps1
FSLogix-RemoveContainerData.ps1 must be run outside the user session when Profile Containers are not in use. The script will require exclusive access to the Container to mount it with read/write access. Remove-ContainerData.ps1 could be run as a schedule task outside of business hours from a management host.
