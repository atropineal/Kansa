<#
Get-NetstatDistinctLocal16.ps1
Requires logparser.exe in path
Pulls distinct /16 local network addresses. Useful for building the 
filter for local addresses in other analysis scripts, so you can see
what hosts are communicating to hosts outside your environment.

This script exepcts files matching the pattern 
*netstat.csv to be in the current working
directory
#>

if (-Not (Test-Path -Path "*netstat.csv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
}
    
$lpquery = @"
    SELECT
        Distinct substr(LocalAddress, 0, last_index_of(substr(LocalAddress, 0, last_index_of(LocalAddress, '.')), '.')) as Local/16
    FROM
        *netstat.csv
    ORDER BY
        Local/16
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 $lpquery