<#
.SYNOPSIS
Get-SvcTrigStack.ps1
Requires logparser.exe in path
Pulls stack rank of Service Triggers from acquired Service Trigger data

This script expects files matching the pattern *svctrigs.tsv to be in 
the current working directory.
.NOTES
DATADIR SvcTrigs
#>

if (-Not (Test-Path -Path "*svctrigs.csv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
}

$lpquery = @"
    SELECT
        COUNT(Type, Subtype, Data) as ct, 
        ServiceName, 
        Action, 
        Type,
        Subtype, 
        Data 
    FROM
        *svctrigs.csv
    GROUP BY
        ServiceName, 
        Action, 
        Type,
        Subtype, 
        Data 
    ORDER BY
        ct ASC
"@
& logparser  -stats:off -i:csv -dtlines:0 -rtp:-1 $lpquery