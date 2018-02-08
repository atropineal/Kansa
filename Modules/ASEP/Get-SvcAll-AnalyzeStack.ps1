<#
.SYNOPSIS
Get-SvcAllStack.ps1
A basic stack for services aggregating on Caption and Pathname.
Out put is fairly ugly, it is sorted by Name, rather than count.
Sorting this way means that items with the same Caption, but 
different Pathnames will be reported next to each other. Here's
an example:

2 HP Version Control Age... {@{Caption=HP Version Control Agent; PathName="C:\hp\hpsmh\data\cgi-bin\vcagent\vcagent.exe"}, @{Caption=HP Version Control Agent; PathName="C:\hp\hpsmh\data\cgi-bin\vcagent\vcagent.exe"}}
1 HP Version Control Age... {@{Caption=HP Version Control Agent; PathName=C:\hp\hpsmh\data\cgi-bin\vcagent\vcagent.exe}}

Here we have scan resunts from three systems. All three have a
service named "HP Version Control Agent,", but one of them has
a pathname without double-quotes. A superficial difference.

Get-Autorunsc.ps1 provides much of the same information, but
Get-SvcAll.ps1 shows Process Ids for running processes and tells
you which account the item is running under.
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
        StartMode,
        DisplayName
    FROM
        *svcall.csv
    GROUP BY
        Name,
        PathName,
        StartMode,
        DisplayName
    ORDER BY
        ct ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"