<#
.SYNOPSIS
Get-ProcsWMIPathStack.ps1

Pulls frequency of processes based on path ProcessName

Requires:
Process data matching *ProcWMI.csv in pwd
logparser.exe in path
#>

if (-Not (Test-Path -Path "*ProcsWMI.csv")) {
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
        COUNT(Path) as ct,
        Path
    FROM
        *ProcsWMI.csv
    GROUP BY
        Path
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"