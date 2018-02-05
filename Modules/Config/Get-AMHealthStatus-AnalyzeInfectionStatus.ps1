<#
.SYNOPSIS
Get-AMInfectionStatusStack.ps1

Returns frequency count of the following fields:
ComputerStatus, CriticallyFailedDetections, PendingFullScan, 
PendingManualSteps, PendingOfflineScan, PendingReboot, 
RecentlyCleanedDetections, SchemaVersion

Requires:
Process data matching *AMInfectionStatus.tsv in pwd logparser.exe in path
.NOTES
DATADIR AMHealthStatus
#>

if (-Not (Test-Path -Path "*AMInfectionStatus.tsv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
}

$lpquery = @"
    SELECT count (
        ComputerStatus, 
        CriticallyFailedDetections, 
        PendingFullScan, 
        PendingManualSteps, 
        PendingOfflineScan, 
        PendingReboot, 
        RecentlyCleanedDetections, 
        SchemaVersion) AS cnt,
        ComputerStatus, 
        CriticallyFailedDetections, 
        PendingFullScan, 
        PendingManualSteps, 
        PendingOfflineScan, 
        PendingReboot, 
        RecentlyCleanedDetections, 
        SchemaVersion
    FROM
        *AMInfectionStatus.tsv
    GROUP BY
        ComputerStatus, 
        CriticallyFailedDetections, 
        PendingFullScan, 
        PendingManualSteps, 
        PendingOfflineScan, 
        PendingReboot, 
        RecentlyCleanedDetections, 
        SchemaVersion
    ORDER BY
        CNT ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -fixedsep:on -rtp:-1 "$lpquery"