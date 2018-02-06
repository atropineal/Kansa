<#
.SYNOPSIS
Get-ProcsWMITempExePath.ps1

Returns DISTINCT process CreationDate, ProcessId, ParentProcessId, CommandLine, 
PSComputerName for any processes with ExecutablePaths containing Temp, Tmp or 
AppData\Local, common temporary folders

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
    SELECT DISTINCT
        CreationDate,
        ProcessId,
        ParentProcessId,
        ExecutablePath,
        CommandLine,
        PSComputerName
    FROM
        *ProcsWMI.tsv
    WHERE
        ExecutablePath like '%Temp%' or
        ExecutablePath like '%Tmp%' or
        ExecutablePath like '%AppData\Local%'
    ORDER BY
        PSComputerName,
        CreationDate,
        ProcessId ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"