if (-Not (Test-Path -Path "*WMIEventFilterConsumerBinding.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,filter,consumer from *WMIEventFilterConsumerBinding.csv group by filter,consumer order by ct"