if (-Not (Test-Path -Path "*netconnections.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct, process from *netconnections.csv where state = 'Listen' and process is not null group by process order by ct,process"