if (-Not (Test-Path -Path "*svcall.csv")) {
    return
}
Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,name,pathname,startmode,startname,caption from *svcall.csv where pathname not like '%svchost.exe%' group by name,pathname,startmode,startname,caption order by ct"