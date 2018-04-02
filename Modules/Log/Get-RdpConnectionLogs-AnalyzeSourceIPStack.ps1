if (-Not (Test-Path -Path "*rdpconnectionlogs.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,sourceip,count(*) as ct from *rdpconnectionlogs.csv group by pscomputername,sourceip order by pscomputername,sourceip"