<#
.SYNOPSIS
Get-ProcsWMISortByStartTime.ps1

Returns process CreationDate, ProcessId, ParentProcessId, CommandLine

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
    SELECT DISTINCT
        CreationDate,
        ProcessId,
        ParentProcessId,
        CommandLine,
        PSComputerName
    FROM
        *ProcsWMI.csv
    ORDER BY
        PSComputerName,
        CreationDate,
        ProcessId ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"