if (-Not (Test-Path -Path "*netconnections.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,process,remoteaddress,remoteport from *netconnections.csv where state <> 'Listen' and state <> 'Bound' and process is not null group by process,remoteaddress,remoteport order by ct,process,remoteaddress,remoteport"