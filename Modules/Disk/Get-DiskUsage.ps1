<#
.SYNOPSIS
Get-DiskUsage.ps1 returns output of Sysinternals' du.exe, which shows disk usage on a per directory basis.
.NOTES
OUTPUT tsv
BINDEP .\Modules\bin\du.exe
!!THIS SCRIPT ASSUMES DU.EXE WILL BE IN THE PATH !!
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=1)]
        [String]$BasePath="C:\"
)

if (Get-Command "du.exe") {
    & du.exe -accepteula -nobanner -q -c -l 2 $BasePath 2> $null | ConvertFrom-Csv
} else {
    Write-Error "du.exe not found in PATH..."
}