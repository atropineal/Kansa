<#
.SYNOPSIS
Get-ASEPImagePathLaunchStringStack.ps1
Requires logparser.exe in path
Pulls frequency of autoruns based on ImagePath, LaunchString tuple
where ImagePath is not 'File not found'

This script expects files matching the pattern *autorunsc.txt to be in the
current working directory.
.NOTES
DATADIR Autorunsc
#>

if (Get-Command logparser.exe) {

    $lpquery = @"
    SELECT
        COUNT(Image\u0020Path, Launch\u0020String, Signer) as ct,
        Image\u0020Path,
        Launch\u0020String
    FROM
        *autorunsc.csv
    WHERE
        (Image\u0020Path not like 'File not found%')
    GROUP BY
        Image\u0020Path,
        Launch\u0020String
    ORDER BY
        ct ASC
"@

    & logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}

