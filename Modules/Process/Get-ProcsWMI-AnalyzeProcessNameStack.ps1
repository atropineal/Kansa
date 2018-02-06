<#
.SYNOPSIS
Get-ProcsWMIProcessNameStack.ps1

Pulls frequency of processes based on path ProcessName

Requires:
Process data matching *ProcWMI.tsv in pwd
logparser.exe in path
#>

if (-Not (Test-Path -Path "*ProcsWMI.tsv")) {
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
        COUNT(ProcessName) as ct,
        ProcessName
    FROM
        *ProcsWMI.tsv
    GROUP BY
        ProcessName
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"