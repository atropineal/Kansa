<#
.SYNOPSIS
Get-SvcAllRunningAuto.ps1
Parses through the Get-SvcAll.ps1 data and returns
those items that are running or set to start automatically.
#>

if (-Not (Test-Path -Path "*svcall.csv")) {
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
        COUNT(Name,PathName,DisplayName) as ct,
        Name,
        PathName,
        DisplayName
    FROM
        *svcall.csv
    WHERE
        StartMode = 'Auto'
    GROUP BY
        Name,
        PathName,
        DisplayName
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"