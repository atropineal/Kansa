[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=0)]
        [String]$File
) 
get-filehash $file