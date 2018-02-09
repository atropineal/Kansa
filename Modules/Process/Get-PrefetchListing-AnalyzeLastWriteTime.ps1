<#
.SYNOPSIS
Get-PrefetchListingLastWriteTime.ps1
Requires logparser.exe in path
Pulls PrefetchListing data sorted by LastWriteTimeUtc Descending
on collected Get-PrefetchListing data.

This script exepcts files matching the pattern 
*PrefetchListing.tsv to be in the current working
directory
#>

if (-Not (Test-Path -Path "*PrefetchListing.csv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
}

Write-Host Running $(Split-Path $PSCommandPath -Leaf)

$lpquery = @"
    SELECT
        FullName,
        LastWriteTimeUtc,
        PSComputerName
    FROM
        *PrefetchListing.csv
    ORDER BY
        LastWriteTimeUtc Desc
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 $lpquery