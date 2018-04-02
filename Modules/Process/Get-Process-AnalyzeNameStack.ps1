Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,name from *.csv group by name order by ct,name"