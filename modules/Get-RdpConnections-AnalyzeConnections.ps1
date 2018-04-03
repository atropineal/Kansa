if (-Not (Test-Path -Path "*rdpconnections.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,username,sourceip from *rdpconnections.csv order by pscomputername"