if (-Not (Test-Path -Path "*WMIEventFilterConsumerBinding.csv")) {
    return
}

if (-Not (Get-Command logparser.exe)) {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    Write-Host "${ScriptName} requires logparser.exe in the path."
    return
} 

Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,filter,consumer from *WMIEventFilterConsumerBinding.csv group by filter,consumer order by ct"