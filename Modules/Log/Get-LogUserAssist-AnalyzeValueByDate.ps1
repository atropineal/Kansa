<#
.SYNOPSIS
Get-LogUserAssistValueByDate.ps1
Requires logparser.exe in path
Returns UserAssist data sorted by KeyLastWritetime descending

This script expects files matching the *LogUserAssist.tsv pattern to be in the
current working directory.
#>


if (-Not (Test-Path -Path "*LogUserAssist.tsv")) {
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
        UserAcct,
        UserPath,
        Subkey,
        KeyLastWriteTime,
        Value,
        Count,
        PSComputerName
    FROM
        *LogUserAssist.tsv
    ORDER BY
        KeyLastWriteTime DESC
"@

& logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"