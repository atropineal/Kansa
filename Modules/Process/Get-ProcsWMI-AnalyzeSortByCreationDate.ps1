<#
.SYNOPSIS
Get-ProcsWMISortByStartTime.ps1

Returns process CreationDate, ProcessId, ParentProcessId, CommandLine

Requires:
Process data matching *ProcWMI.tsv in pwd
logparser.exe in path
.NOTES
DATADIR ProcsWMI
#>

if (-Not (Test-Path -Path "*ProcsWMI.tsv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
}

$lpquery = @"
    SELECT DISTINCT
        CreationDate,
        ProcessId,
        ParentProcessId,
        CommandLine,
        PSComputerName
    FROM
        *ProcsWMI.tsv
    ORDER BY
        PSComputerName,
        CreationDate,
        ProcessId ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"