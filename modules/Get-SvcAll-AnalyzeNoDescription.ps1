if (-Not (Test-Path -Path "*svcall.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select pscomputername,name,pathname,startmode,startname,caption from *svcall.csv where description is null order by name"