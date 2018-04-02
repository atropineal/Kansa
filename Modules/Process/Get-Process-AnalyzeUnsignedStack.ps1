Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,path from *.csv where company is null and path is not null group by path order by ct,path"