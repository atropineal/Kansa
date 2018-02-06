<#
.SYNOPSIS
Get-ASEPImagePathLaunchStringStack.ps1
Requires logparser.exe in path
Pulls frequency of autoruns based on ImagePath, LaunchString and Publisher tuple
where ImagePath is not 'File not found'

This script expects files matching the pattern *autorunsc.txt to be in the
current working directory.
.NOTES
DATADIR Autorunsc
#>

if (-Not (Test-Path -Path "*-autorunsc.csv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
}

$lpquery = @"
    SELECT
        COUNT(Image\u0020Path, Launch\u0020String, Signer) as ct,
        Image\u0020Path,
        Launch\u0020String,
        Signer
    FROM
        *autorunsc.csv
    WHERE
        (Image\u0020Path not like 'File not found%')
    GROUP BY
        Image\u0020Path,
        Launch\u0020String,
        Signer
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"