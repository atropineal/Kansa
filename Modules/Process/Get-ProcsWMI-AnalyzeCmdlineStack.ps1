<#
.SYNOPSIS
Get-ProcsWMICmdLineStack.ps1

Pulls frequency of processes based on path CommandLine

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
        COUNT(CommandLine) as ct,
        CommandLine
    FROM
        *ProcsWMI.csv
    GROUP BY
        CommandLine
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"