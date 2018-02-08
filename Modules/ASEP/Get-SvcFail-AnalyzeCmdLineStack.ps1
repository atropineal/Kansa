<#
.SYNOPSIS
Get-SvcFailCmdLineStack.ps1
Requires logparser.exe in path
Pulls stack rank of Service Failure CmdLines from acquired Service Failure data
where CmdLine is not 'customScript.cmd' nor NULL

This script expects files matching the pattern *SvcFail.csv to be in 
the current working directory.
#>

if (-Not (Test-Path -Path "*SvcFail.csv")) {
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
        COUNT(To_Lowercase(CmdLine)) as ct, 
        To_Lowercase(CmdLine) as CmdLineLC
    FROM
        *SvcFail.csv
    GROUP BY
        CmdLineLC
    ORDER BY
        ct,CmdLineLC ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 $lpquery