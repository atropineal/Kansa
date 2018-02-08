<#
.SYNOPSIS
Get-AMHealthStatusStack.ps1

Returns the following fields:
AntispywareEnabled, AntispywareSignatureAge, 
AntispywareSignatureVersion, AntivirusEnabled, AntivirusSignatureAge, 
AntivirusSignatureVersion, BehaviorMonitorEnabled, Enabled,
EngineVersion, IoavProtectionenabled, Name, NisEnabled, 
NisEngineVersion, NisSignatureVersion, OnAccessProtectionEnabled,
ProductStatus, RealTimeScanDirection, RtpEnabled, SchemaVersion,
Version

Requires:
Process data matching *AMHealthStatus.tsv in pwd logparser.exe in path
#>

if (-Not (Test-Path -Path "*AMHealthStatus.csv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
}

Write-Host Running $(Split-Path $PSCommandPath -Leaf)

$lpquery = @"
    SELECT count (
        AntispywareEnabled, 
        AntispywareSignatureAge, 
        AntispywareSignatureVersion,
        AntivirusEnabled, 
        AntivirusSignatureAge, 
        AntivirusSignatureVersion, 
        BehaviorMonitorEnabled, 
        Enabled,
        EngineVersion, 
        IoavProtectionenabled, 
        Name, 
        NisEnabled,
        NisEngineVersion, 
        NisSignatureVersion, 
        OnAccessProtectionEnabled,
        ProductStatus, 
        RealTimeScanDirection, 
        RtpEnabled, 
        SchemaVersion,
        Version) AS CNT,
        AntispywareEnabled, 
        AntispywareSignatureAge, 
        AntispywareSignatureVersion,
        AntivirusEnabled, 
        AntivirusSignatureAge, 
        AntivirusSignatureVersion, 
        BehaviorMonitorEnabled, 
        Enabled,
        EngineVersion, 
        IoavProtectionenabled, 
        Name, 
        NisEnabled,
        NisEngineVersion, 
        NisSignatureVersion, 
        OnAccessProtectionEnabled,
        ProductStatus, 
        RealTimeScanDirection, 
        RtpEnabled, 
        SchemaVersion,
        Version
    FROM
        *AMHealthStatus.csv
    GROUP BY
        AntispywareEnabled, 
        AntispywareSignatureAge, 
        AntispywareSignatureVersion,
        AntivirusEnabled, 
        AntivirusSignatureAge, 
        AntivirusSignatureVersion, 
        BehaviorMonitorEnabled, 
        Enabled,
        EngineVersion, 
        IoavProtectionenabled, 
        Name, 
        NisEnabled,
        NisEngineVersion, 
        NisSignatureVersion, 
        OnAccessProtectionEnabled,
        ProductStatus, 
        RealTimeScanDirection, 
        RtpEnabled, 
        SchemaVersion,
        Version
    ORDER BY
        CNT ASC
"@
& logparser -stats:off -i:csv -dtlines:0 -rtp:-1 "$lpquery"

