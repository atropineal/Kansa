if (-Not (Test-Path -Path "*rdpconnectionlogs.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,username,sourceip from *rdpconnectionlogs.csv order by pscomputername"