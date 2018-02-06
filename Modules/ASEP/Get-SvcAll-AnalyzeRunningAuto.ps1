<#
.SYNOPSIS
Get-SvcAllRunningAuto.ps1
Parses through the Get-SvcAll.ps1 data and returns
those items that are running or set to start automatically.
#>

if (-Not (Test-Path -Path "*svcall.xml")) {
    return
}

Write-Host Running $(Split-Path $PSCommandPath -Leaf)

$data = $null

foreach ($file in (ls *svcall.xml)) {
    $data += Import-Clixml $file
}

$data | ? { $_.StartMode -eq "Auto" -or $_.State -eq "Running" }