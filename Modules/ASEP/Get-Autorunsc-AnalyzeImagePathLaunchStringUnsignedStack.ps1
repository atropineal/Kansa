<#
.SYNOPSIS
Get-ASEPImagePathLaunchStringStack.ps1
Requires logparser.exe in path
Pulls frequency of autoruns based on ImagePath and LaunchString tuple where
for unsigned code and where the ImagePath is not 'File not found'

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
        COUNT(Image\u0020Path, Launch\u0020String) as ct,
        Image\u0020Path,
        Launch\u0020String
    FROM
        *autorunsc.csv
    WHERE
        Signer not like '(Verified)%' and
        (Image\u0020Path not like 'File not found%')
    GROUP BY
        Image\u0020Path,
        Launch\u0020String
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"
