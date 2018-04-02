if (-Not (Test-Path -Path "*rdpconnections.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,username,count(*) as ct from *rdpconnections.csv group by pscomputername,username order by pscomputername,username"