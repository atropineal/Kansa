<#
.SYNOPSIS
Get-ASEPImagePathLaunchStringStack.ps1
Requires logparser.exe in path

Pulls frequency of autoruns based on ImagePath, LaunchString and MD5 tuple
where the publisher is not verified (unsigned code) and the ImagePath is
not 'File not found'

This script expects files matching the *autorunsc.csv pattern to be in the
current working directory.
#>

if (-Not (Test-Path -Path "*-autorunsc.csv")) {
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
        COUNT(Image\u0020Path, Launch\u0020String, MD5) as ct,
        Image\u0020Path,
        Launch\u0020String,
        MD5,
        Signer
    FROM
        *autorunsc.csv
    WHERE
        Signer not like '(Verified)%' and
        (Image\u0020Path not like 'File not found%')
    GROUP BY
        Image\u0020Path,
        Launch\u0020String,
        MD5,
        Signer
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"

