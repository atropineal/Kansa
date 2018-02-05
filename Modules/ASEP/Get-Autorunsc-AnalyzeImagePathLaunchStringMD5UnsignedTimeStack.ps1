<#
Get-ASEPImagePathLaunchStringTimeStack.ps1
Requires logparser.exe in path

Pulls frequency of autoruns based on ImagePath, LaunchString and MD5 
tuple where the publisher is not verified (unsigned code) and the 
ImagePath is not 'File not found'

This one also includes the time stamp, which may break aggregation, but
provides some useful information.

This script expects files matching the *autorunsc.txt pattern to be in
the current working directory.
.NOTES
DATADIR Autorunsc
#>


if (Get-Command logparser.exe) {
    $lpquery = @"
    SELECT
        COUNT(Image\u0020Path, Launch\u0020String, MD5) as ct,
        Image\u0020Path,
        Launch\u0020String,
        MD5,
        Time,
        Signer
    FROM
        *autorunsc.csv
    WHERE
        Image\u0020Path is not null and
        Signer not like '(Verified)%' and
        (Image\u0020Path not like 'File not found%')
    GROUP BY
        Image\u0020Path,
        Launch\u0020String,
        MD5,
        Time,
        Signer
    ORDER BY
        ct ASC
"@

    & logparser -i:csv -dtlines:0 -rtp:-1 "$lpquery"

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
