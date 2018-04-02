if (-Not (Test-Path -Path "*rdpconnectionlogs.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,username,count(*) as ct from *rdpconnectionlogs.csv group by pscomputername,username order by pscomputername,username"