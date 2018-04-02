Write-Host Running $(Split-Path $PSCommandPath -Leaf)
& logparser /q:on "select count(*) as ct,name from *.csv where path like '%\\temp\\%' or path like '%\\appdata\\%' group by name order by ct,name"