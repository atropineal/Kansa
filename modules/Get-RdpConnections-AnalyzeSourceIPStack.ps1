if (-Not (Test-Path -Path "*rdpconnections.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,sourceip,count(*) as ct from *rdpconnections.csv group by pscomputername,sourceip order by pscomputername,sourceip"