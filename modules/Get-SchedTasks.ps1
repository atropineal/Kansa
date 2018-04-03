<#
.SYNOPSIS
Get-ShedTasks.ps1 returns information about all Windows Scheduled Tasks.
The output of schtasks has to be processed to remove duplicate headers.
#>
# Run schtasks and convert csv to object
$CSV = schtasks /query /FO CSV /v 
$Headers = ($CSV -Split '\n')[0]
$HeadersRemoved = ($CSV | Where-Object { $_ -NotMatch $Headers }) -join "`r`n" | Out-String
$Output = $Headers + "`r`n" + $HeadersRemoved | ConvertFrom-Csv
$Output